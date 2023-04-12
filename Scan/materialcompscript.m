function [material_array] = materialcompscript(filename)

%% Create material composition array from .csv file (comma delimited)
% Includes error correction:
% If composition does not sum up to 100, water will be added/subtracted
% such that compositon sums up to 100 (to correct for rounding error)
comparray = dlmread(filename,',');
for i = 1:size(comparray,1)
    if 100-abs(sum(comparray(i,1:4))) ~= 0
        if sum(comparray(i,1:4)) ~= 100
            comparray(i,1) = 100 - sum(comparray(i,2:4));
        end       
    end
end

%% Create material string for crosssect
materialstring = cell(size(comparray,1),1);
for i = 1:size(comparray,1)
    materialstring{i} = ['Water' num2str(comparray(i,1)) 'Lipid' num2str(comparray(i,2)) ...
        'Protein' num2str(comparray(i,3)) 'Calcium' num2str(comparray(i,4))];
end
%% Create nested cells for trials
% Each trial is composed of 2 materials and Striated Muscle
for j = 0: 2:ceil(size(materialstring,1))
    for i = 1:2
        if i == 1
            if i+j > size(materialstring,1)
                material_trial(1,1) = materialstring(i+j-2);
                material_trial(1,4) = materialstring(i+j-2);
            else
                material_trial(1,1) = materialstring(i+j);
                material_trial(1,4) = materialstring(i+j);
            end
        else
            if i+j > size(materialstring,1)
                material_trial(1,2) = materialstring(i+j-2);
                material_trial(1,5) = materialstring(i+j-2);
            else
                material_trial(1,2) = materialstring(i+j);
                material_trial(1,5) = materialstring(i+j);
            end
        end
        material_trial(1,3) = {'Striated Muscle'};
    end
    material_array(j/2+1) = {material_trial};
end
end