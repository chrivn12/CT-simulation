%% Load base thorax phantom tiff, without any vessels added:

imBase = TiffStackRead('calcified_vessles.tif');
imPhantom = imBase;
posY_heart = 1575; %px
posX_heart = 930; %px

rad_heart = 500; %px, radius of heart

%% Validate estimated center:

imtool3D(MidpointCircle(imBase, 100, posX_heart, posY_heart,500));


%% Add decreasing radius circles

numVessels = 5;

indexedValues = 300 : numVessels : 350 + numVessels^2;
vRadius = linspace(100,100,numVessels); % radius in px

% TO ROTATE:
n = 0; % change any number between 1 and numVessels
indexedValues = circshift(indexedValues',n);
vRadius = circshift(vRadius',n);

% Get center points for edge:

centerPts = circEdgePt(posX_heart, posY_heart, rad_heart, numVessels, 150, true); % 150 stands for the space from the edge

% Plot circles:

for i = 1:length(centerPts)
    imPhantom = MidpointCircle(imPhantom, vRadius(i), centerPts(i,1), centerPts(i,2), indexedValues(i));
end
imtool3D(imPhantom);