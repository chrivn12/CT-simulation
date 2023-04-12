function [ phantom ] = PhantomGene(n_vessels, r_vessels, m_vessels )
%NEWPHANTOMGENE creates an IndexedPhantom object, with vessels, for QRM phantom CT Simulation.
%
%   newPhantomGene creates an IndexedPhantom object with equidistance
%   vessels of fixed radius.  It will also assign ALL vessels with the
%   inputted material.  This function will also add a materialMask to the
%   outputted phantom, to be used to automate analysis of the simulated
%   image.
%
%   INPUTS:
% 
%   n_vessels                     Number of vessels (scalar)
% 
%   r_vessels                     Radius of vessels (scalar array, in cm)
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
%   DATE CREATED: 12-Nov-2021
%    
%   AUTHOR:       Shu Nie
%   DATE UPDATED: 11-Nov-2022
%   add marrow to phantom
% 

% im_phantom = TiffStackRead('thorax_resized4x.tif'); % previous phantom
load('phantom_with_marrow.mat'); % new phantom with marrow
im_phantom = phantom_new;
im_size = size(im_phantom);
element_size = .01; %cm/px;
vessel_mask = zeros(im_size);
posY_heart = 1575; %px
posX_heart = 930; %px
rad_heart = 500; %px, radius of heart

m_vessels = {m_vessels{:}, m_vessels{:},m_vessels{:}};
n1 = n_vessels*3;
% CREATE PHANTOM IMAGE:
r_vessels = r_vessels / element_size;
vessel_idx = (300 : n1 : 350 + n1^2)';
v_radii = [linspace(r_vessels(1),r_vessels(1),3),linspace(r_vessels(2),r_vessels(2),3),linspace(r_vessels(3),r_vessels(3),3) ]';

% Get center points for edge:

centerPts = circEdgePt(posX_heart, posY_heart, rad_heart, n_vessels, 150, false); % 150 stands for the space from the edge
centerPts = [centerPts; circEdgePt(posX_heart, posY_heart, rad_heart, n_vessels, 250, false)];
centerPts = [centerPts; circEdgePt(posX_heart, posY_heart, rad_heart, n_vessels, 320, false)];

% Linear Transformation
T = [cos(13*pi/30) cos(28*pi/30);sin(13*pi/30) sin(28*pi/30)];
new_CenterPts = [];
for i = 1:length(centerPts)
    v = centerPts(i,:)'-[posX_heart;posY_heart];
    new_CenterPts = [new_CenterPts; (T*v)'+[posX_heart posY_heart]];
end
clear centerPts;
clear v;

% Plot circles:
roi_scale = .75; % relative size of roi to measure for vessels
for i = 1:length(new_CenterPts)
    im_phantom        = MidpointCircle(im_phantom, v_radii(i),new_CenterPts(i,1), new_CenterPts(i,2), vessel_idx(i));
%     vessel_mask       = MidpointCircle(vessel_mask, v_radii(i), centerPts(i,1), centerPts(i,2), 600); % can be removed, just for visualization
    vessel_mask       = MidpointCircle(vessel_mask, v_radii(i) * roi_scale, new_CenterPts(i,1), new_CenterPts(i,2), vessel_idx(i)); % This ROI is used to measure ROI of each vessel - for automating the analysis
    % ADD ANOTHER CIRCLE - DIFFERENT RADIUS - IF SMALLER, THEN IT IS LUMEN
end

% INITIATE INDEXEDPHANTOM OBJECT:
phantom = IndexedImagePhantom();
phantom.element_size = [element_size element_size];
phantom.indexed_image = im_phantom;

% Set default materials: (shouldn't be changed)
material_default = {'Air, Dry (near sea level)', 'Water',...
                    'Air, Dry (near sea level)', 'Lung (LN300)', ...
                    'Striated Muscle',           'B-100 Bone-Equivalent Plastic', ...
                    'Water19.08Lipid78.75Protein2.17',     'Skeleton-Red Marrow'};
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
