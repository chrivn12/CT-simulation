function [phantom] = Copy_of_rodGene(r,m )
%rodGene creates an IndexedPhantom object, with only one calibration rod, for QRM phantom CT Simulation.
%
%   rodGene creates an IndexedPhantom object with equidistance
%   vessels of fixed radius.  It will also assign ALL vessels with the
%   inputted material.  This function will also add a materialMask to the
%   outputted phantom, to be used to automate analysis of the simulated
%   image.
%
%   INPUTS:
% 
%   n_vessels                     Number of vessels (scalar)
% 
%   r_vessels                     Radius of vessels (scalar, in cm)
%
%   m_vessels                     Material to set for each vessel (string
%                                 array)
%
%
%   OUTPUTS:
%
%   phantom                       IndexedPhantom to be used for simulation.
%
%   REFERENCE:    GeneratePhantomCirc
%   AUTHOR:       Xingshuo Xiao
%   DATE CREATED: 1-Mar-2022
%

% im_phantom = TiffStackRead('thorax_resized4x.tif');
load('phantom_new-2.mat');
im_phantom = phantom_new;
im_size = size(im_phantom);
element_size = .01; %cm/px;
vessel_mask = zeros(im_size);
posY_heart = 1575; %px
posX_heart = 930; %px
rad_heart = 500; %px, radius of heart

m_vessels = {m};
% CREATE PHANTOM IMAGE:
r = r / element_size;
vessel_idx = 300;


roi_scale = .75; % relative size of roi to measure for vessels
im_phantom        = MidpointCircle(im_phantom, r ,posX_heart, posY_heart, 300);
vessel_mask       = MidpointCircle(vessel_mask, r * roi_scale, posX_heart, posY_heart, 300); % This ROI is used to measure ROI of each vessel - for automating the analysis


% INITIATE INDEXEDPHANTOM OBJECT:
phantom = IndexedImagePhantom();
phantom.element_size = [element_size element_size];
phantom.indexed_image = im_phantom;

% Set default materials: (shouldn't be changed)
material_default = {'Air, Dry (near sea level)', 'Water',...
                    'Air, Dry (near sea level)', 'Lung (LN300)', ...
                    'Striated Muscle',           'B-100 Bone-Equivalent Plastic', ...
                    'Water20.2Lipid76.7Protein3.1',         'Skeleton-Red Marrow'};
material = horzcat(material_default, m_vessels);
idx_default = [ 1000 2000 80 90 100 150 10 200];
idx = [ idx_default vessel_idx' ];

% Determine scale for material mask:  (for automated vessel analysis)
real_size = phantom.physical_size ./ .05; % (cm) size of Aquilion detector width
scale_factor = real_size(1) / im_size(1);
vessel_mask = imresize(vessel_mask , scale_factor, 'nearest');

% Add fields to phantom object:
phantom.vessel_mask         = vessel_mask;
phantom.vessel_material     = m_vessels;
phantom.vessel_idx          = vessel_idx;
phantom.material_list       = material;
phantom.indexed_values      = idx;

end


