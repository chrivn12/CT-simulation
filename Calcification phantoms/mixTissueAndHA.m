function tissueComp = mixTissueAndHA( HAfracMass )
% Creates a material that simluates a mix of glandular and adipose tissue.
%
% inputString is expected to be like 'TissueAndHA07' or 'TissueAndHA56'
% where the last two numbers give the volume fraction of hydroxyapatite in the
% desired composite tissue.
% 
% Outputs a cell array describing the characteristics of the material.

% {'Hydroxyapatite',3.156,[1 8 15 20],[0.002 0.4141 0.185 0.3989]}
% {'Striated Muscle',1.04,[1 6 7 8 11 12 15 16 19],[0.102 0.123 0.035 0.729 0.0008 0.0002 0.002 0.005 0.003]}

roHA = 3.156;
roTissue = 1.04;
HAfrac = HAfracMass/roHA/1000;
if HAfrac > 1
    error('Fraction of hydroxyapatite cannot exceed 1')
end
Tissuefrac = 1 - HAfrac;
% Densities and zFractions from Hammerstien


zFracTissue = [0.102 0.123 0.035 0.729 0.0008 0.0002 0.002 0.005 0.003 0.000];
zFracHA = [0.002 0.000000000 0.000000000 0.4141 0.000000000 0.000000000 0.185 0.000000000 0.000000000 0.3989];

density = HAfrac * roHA + Tissuefrac * roTissue;

% The zFrac arrays give the mass fractions of each element.
% From the volume fraction, density, and mass fraction, here we calculate
% the mass of each element in the composite material
zFracs = HAfrac * roHA * zFracHA + Tissuefrac * roTissue * zFracTissue;
% Then we divide by the total mass to get mass fractions back
zFracs = zFracs / sum( zFracs(:) );
name = ['HA ',int2str(HAfracMass),'mg.ml'];
tissueComp = {name, density, [1, 6, 7, 8, 11, 12, 15, 16, 19, 20], zFracs};
