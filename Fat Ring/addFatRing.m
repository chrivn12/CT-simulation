function [ new_phantom ] = addFatRing( p, x, y)
% addFatRing creates an IndexedPhantom object for QRM phantom simulation.
%   It adds a fat ring to the original indexed phantom object to simulate  
%   the change the size of the patient

i = p.indexed_image;
new_x = x*100;
new_y = y*100;
%% Prepare the indexed image
i = changeCorner(i);

%% Prepare the fat ring
% load('baseRing.mat'); 
% baseRing.mat has idx = 100 'Striated Muscle' in default
load('fatRing_single.mat'); 
% fatRing, idx = 10 -> set idx =10 'Adipose Tissue (ICRU-44)' in phantoms
ring = imresize(ring, [new_y, new_x]);
ring = fill_Air(ring);

%% Load and add fat ring
[y,x] = size(ring);
y_i = (y-2200)/2+1;
x_i = (x-3200)/2+1;
new_i = ring;
new_i(y_i:y_i+2200-1,x_i:x_i+3200-1) = i;
air = find(ring == 0);
new_i(air) = 80;
    %new_i is the wanted indexed image

%% Replace the indexed image and vessel mask of the phantom
v = p.vessel_mask;
y_v = y/5;
x_v = x/5;
new_v = zeros(y_v, x_v);
v_x = (x_v-size(v,2))/2+1;
v_y = (y_v-size(v,1))/2+1;
new_v(v_y:v_y+size(v,1)-1,v_x:v_x+size(v,2)-1) = v;
new_phantom = p;
new_phantom.vessel_mask = new_v;
new_phantom.indexed_image = new_i;

end

