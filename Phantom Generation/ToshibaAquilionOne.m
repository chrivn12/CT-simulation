function [ Recon, RealSinogram, SinoNoNoise, SinoWithNoise] = ToshibaAquilionOne( energy, exposure, phantom )
%TOSHIBAAQUILLIONONE simulates CT scanner.
%
%   ToshibaAquillionOne simulates CT scanner, using proper projections,
%   allowing for variable levels of energy and exposure.  Adds Poisson
%   noise.  The first material of the Phantom must be AIR and the second
%   MUST BE WATER, to properly convert to HU.
%
%   INPUTS:
%
%   energy                        KVp of simulation
%
%
%   exposure                      Exposure of simulation in mR
%
%
%   phantom                       IndexedImagePhantom object
%
%
%   OUTPUTS:
%
%   Recon                         Reconstructed image
%
%
%   AUTHOR:       Shant Malkasian
%   DATE CREATED: 26-Aug-2015
%




%HELPER FUNCS==========================================
func_angles = @(n) (0:360/n:360-360/n) .* (pi/180);

% possible values for FilterType:
% none, ram-lak, shepp-logan, cosine, hamming, hann, tukey, lanczos,
% triangular, gaussian, barlett-hann, blackman, nuttall, blackman-harris,
% blackman-nuttall, flat-top, kaiser, parzen
%PARAMS================================================
%XRay Source->
XRS_FILTER  = 'Al';     %    (quoted from Toshiba)
THICKNESS   = 0.75;     %cm  (calibrated with Toshiba)
%Detector->
ELEMENT_WIDTH           = 0.05;     %cm (quoted from Toshiba)
RECON_ELEMENT_WIDTH     = 0.05;     %cm (quoted from Toshiba)
PROJECTION_ANGLES       = func_angles(900);  % 900 projections (quoted from Toshiba)
PROJECTION_TYPE         = 'fanbeam';%   (quoted from Toshiba)
SOURCE_OBJECT_DIST      = 600;      %cm (quoted from Toshiba)
OBJECT_DETECTOR_DIST    = 472;      %cm (quoted from Toshiba)
BACKPROJECTION_FILTER   = 'ram-lak'; % 'none', 'ram-lak'
DETECTOR_MATERIAL       = 'Gadolinium Oxysulfide';      % (quoted from Toshiba for 64-slice Aquillion, should be similar enough)
DETECTOR_THICKNESS      = 0.05;      %cm (not quoted from Toshiba 'proprietary')
DETECTOR_NOISE_TYPE     = 'poisson';
FOCAL_SPOT_SIZE         = 0.09;     %cm (quoted from Toshiba)
FOCAL_SPOT_SIZE         = FOCAL_SPOT_SIZE * (SOURCE_OBJECT_DIST + OBJECT_DETECTOR_DIST)/SOURCE_OBJECT_DIST;


if strcmp(DETECTOR_NOISE_TYPE, 'none')
    warning('DECT: NO NOISE TYPE WAS SPECIFIED');
end
%DEFINE X RAY SOURCE================================
XRS = XRaySource(energy, exposure);
XRS.addFilter(XRS_FILTER,THICKNESS);

%DEFINE GEOMETRY====================================
cfg.projection_type                 = PROJECTION_TYPE;
cfg.detector_element_width          = ELEMENT_WIDTH;
cfg.reconstruction_element_width    = RECON_ELEMENT_WIDTH;
cfg.projection_angles               = PROJECTION_ANGLES;
cfg.source_object_distance          = SOURCE_OBJECT_DIST;
cfg.object_detector_distance        = OBJECT_DETECTOR_DIST;
Geoms                               = SimpleGeometries(phantom,cfg);

%CREATE FORWARD PROJECTOR===========================
FP_impl = MakeAstraForwardProjector(Geoms.VolumeGeometry, Geoms.ProjectionGeometry);
%  if FP_impl.dimensionality == 2 % Comment lines 76-78 to use GPU
%      FP_impl.useGPU = false;
%  end
FP = MaterialForwardProjectorAdapter(FP_impl);

%DEFINE DETECTOR====================================
Detector = ChargeIntegratingDetector(Geoms.ProjectionGeometry);
Detector.noise_type = DETECTOR_NOISE_TYPE;
Detector.focal_spot_blur = FOCAL_SPOT_SIZE * OBJECT_DETECTOR_DIST/SOURCE_OBJECT_DIST;
Detector.detector_material = DETECTOR_MATERIAL;
Detector.detector_thickness = DETECTOR_THICKNESS;

%DEFINE BACK PROJECTOR==============================
BP_params.filter_type = BACKPROJECTION_FILTER;
BP = MakeAstraFilteredBackProjector(Geoms.ProjectionGeometry, Geoms.ReconGeometry, BP_params);
%  if BP.dimensionality == 2 % Comment lines 91-93 to use GPU
%     BP.useGPU = false;
%  end

%CONNECT COMPONENTS=================================
SinoArray = FP.generateSinograms(phantom, XRS.energies);
[RealSinogram, SinoNoNoise, SinoWithNoise] = Detector.filterSinogramArray(XRS, SinoArray);
Recon = BP.reconstruct(RealSinogram);

%CONVERT Recon TO HU================================
phantomMap = phantom.indexed_image;
phantomSize = size(phantomMap);
phantomRealSize = phantom.physical_size ./ ELEMENT_WIDTH;
phantomScaleFactor = phantomRealSize(1) / phantomSize(1);
airValue = phantom.indexed_values(1);
waterValue = phantom.indexed_values(2);
% Resize map to be the same dimensions as the reconstructed image
phantomMap = round(imresize(phantomMap, phantomScaleFactor));
% Remove interpolated points
phantomMap(phantomMap ~= airValue & phantomMap ~= waterValue) = -5000;
meanAirAttenuation = mean(Recon(phantomMap == airValue));
meanWaterAttenuation = mean(Recon(phantomMap == waterValue));

Recon = 1000 .* (Recon - meanWaterAttenuation) ./ (meanWaterAttenuation - meanAirAttenuation);


end