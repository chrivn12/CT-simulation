% This script gives the material mixture with HA of targeted concentration
% (mass fraction) combined with tissue
clear;
roHA = 3.156;
roTissue = 1.04;
% d = [27,32,37,41,48,101,199,403,797]; %mg/cc
d= [50,100,150,200,250,300,350,400,450,500,550,600,650,750,800];
x = zeros(size(d));
comp = {};
for i = 1:numel(d)
    comp{end+1} = mixTissueAndHA(d(i));
end