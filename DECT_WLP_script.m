% Increase in FAI is because of the loss of lipid content rather than water accumulation.
% Initialize trials and modes
modes = {'calibration', 'validation'};
kvps_sizes_modes = {'energy', 'patient_size'};

% Constants
lipid_density = 0.92;
water_density = 1.00;
protein_density = 1.35;
initial_water_mass = 20.2; % g
initial_lipid_mass = 76.7; % g
initial_protein_mass = 3.1; % g
total_mass = initial_water_mass + initial_lipid_mass + initial_protein_mass;

for m = 1:length(modes)
    for n = 1:1 %length(kvps_sizes_modes)
        % Start trials
        mode = modes{m};
        kvps_sizes = kvps_sizes_modes{n};

        % Energy & Patient size
        if strcmp(kvps_sizes, 'energy')
            groupEn = [80,100,120,135];
            groupPS = {'medium','medium','medium','medium'};
            ep = 'Energy';
        else
            groupEn = [120,120,120];
            groupPS = {'small','medium','large'};
            ep = 'Size';
        end
        % Exposure
        if strcmp(mode, 'calibration')
            groupEx = ones(1,length(groupEn))*500;
            cv = 'Calibration';
            trials = 5; % Change the number of trials/experiments
        else
            cv = 'Validation';
            trials = 3;
            if strcmp(kvps_sizes, 'energy')
                groupEx = [6.5,4,2.7,2.4];
            else
                groupEx = [1,2.7,7];
            end
        end

        % Create Excel file
        pathname = sprintf('%s_%s.xlsx',cv,ep);
        xlspath = pathname;
        xlsSESheet = 'Single Energy Analysis';
        line1_sheet1 =  {'Patient Size', 'Energy (kVp)', 'Exposure (mR)','Mean (HU)', 'STD (HU)' , 'Water(%)' , 'Lipid(%)','Protein(%)'};
        line1_sheet1 = horzcat(line1_sheet1);
        xlswrite(xlspath, line1_sheet1, xlsSESheet);
        load('phantom_with_marrow.mat')

        for  k = 1:length(groupEn)
            energy = groupEn(k);
            patientsize = char(groupPS(k));
            exposure =groupEx(k);

            for j = 1:trials
                % 20.2 g W, 76.7g L, 3.1g P
                % Set 19.08cm3 W, 78.75cm3 L, 2.17cm3 P in 100cm3 adipose tissue as healthy
                if strcmp(mode, 'calibration')
                    rng(j); % Set the seed for calibration dataset
                else
                    rng(j + trials); % Set the seed for validation dataset
                end

                % Water weight percentage range: 4.4 - 36.1 g/100 g
                % Lipid weight percentage range: 61.0 - 94.1 g/100 g
                % Protein weight percentage range: 1.0 - 6.5 g/100 g

                % Generate 10 random lipid weight fractions from 61 to 94.1
                lipid_weight_fractions = 61 + (94.1 - 61) .* rand(10, 1);

                % Calculate corresponding water and protein weight fractions
                water_weight_fractions = (initial_water_mass ./ (total_mass - initial_lipid_mass + lipid_weight_fractions * total_mass / 100)) * 100;
                protein_weight_fractions = (initial_protein_mass ./ (total_mass - initial_lipid_mass + lipid_weight_fractions * total_mass / 100)) * 100;

                % Calculate volumetric fractions
                water_volumetric_fractions = 100 .* water_weight_fractions ./ water_density ./ (water_weight_fractions ./ water_density + lipid_weight_fractions ./ lipid_density + protein_weight_fractions ./ protein_density);
                lipid_volumetric_fractions = 100 .* lipid_weight_fractions ./ lipid_density ./ (water_weight_fractions ./ water_density + lipid_weight_fractions ./ lipid_density + protein_weight_fractions ./ protein_density);
                protein_volumetric_fractions = 100 .* protein_weight_fractions ./ protein_density ./ (water_weight_fractions ./ water_density + lipid_weight_fractions ./ lipid_density + protein_weight_fractions ./ protein_density);

                comparray = [water_volumetric_fractions,lipid_volumetric_fractions,protein_volumetric_fractions];
                for i = 1:size(comparray,1)
                    m_vessels{i} = ['Water' num2str(comparray(i,1)) 'Lipid' num2str(comparray(i,2)) 'Protein' num2str(comparray(i,3))];
                end
                m_vessels = {m_vessels{:}};
                n_vessels = length(m_vessels);

                % Create Phantom Image:
                im_phantom = phantom_new;
                im_size = size(im_phantom);
                element_size = .01; %cm/px;
                vessel_mask = zeros(im_size);
                posY_heart = 1575; %pxcl
                posX_heart = 930; %px
                rad_heart = 500; %px, radius of heart
                r_vessels = 0.4; %cm
                r_vessels = r_vessels / element_size;
                vessel_idx = ceil(linspace(300,800,n_vessels));

                % Shift blood vessel 3 cm away from the center
                %     new_centers= getShiftedCenter(posX_heart, posY_heart,300);
                new_centers = [1230,1595];
                im_phantom = MidpointCircle(im_phantom, 25 ,new_centers(1), new_centers(2), 900); % IV contrast, radius 2mm. I 12mg.ml

                % Get center points for inserts:
                centerPts = getCentersWithoutOverlaps(n_vessels, r_vessels, new_centers(1), new_centers(2));

                % Plot circles:
                roi_scale = .7; % relative size of roi to measure for vessels
                for i = 1:length(centerPts)
                    im_phantom        = MidpointCircle(im_phantom, r_vessels, centerPts(i,1), centerPts(i,2), vessel_idx(i));
                    vessel_mask       = MidpointCircle(vessel_mask, r_vessels * roi_scale, centerPts(i,1), centerPts(i,2), vessel_idx(i)); % This ROI is used to measure ROI of each vessel - for automating the analysis
                end

                % Initiate INDEXEDPHANTOM OBJECT:
                phantom               = IndexedImagePhantom();
                phantom.element_size  = [element_size element_size];
                phantom.indexed_image = im_phantom;

                % Set default materials: (shouldn't be changed)
                material_default = {'Air, Dry (near sea level)', 'Water',...
                    'Air, Dry (near sea level)', 'Lung (LN300)', ...
                    'Striated Muscle',           'B-100 Bone-Equivalent Plastic', ... % Bone, Lower Density
                    'I 12mg.ml',                 'Water19.08Lipid78.75Protein2.17', ...
                    'Skeleton-Red Marrow'};
                material = horzcat(material_default, m_vessels);
                idx_default = [ 1000 2000 80 90 100 150 900 10 200];
                idx = [ idx_default vessel_idx ];

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

                % Add fat ring LAT:30-40, AP:20-30
                if strcmp(mode, 'calibration') || strcmp(kvps_sizes, 'energy')
                    if strcmp(patientsize, 'medium')
                        LAT = 35;
                        AP  = 25;
                        phantom = addFatRing(phantom, 35, 25);
                    elseif strcmp(patientsize, 'large')
                        LAT = 40;
                        AP  = 30;
                        phantom = addFatRing(phantom, 40, 30); % QRM Large
                    elseif strcmp(patientsize, 'small')
                        LAT = 30;
                        AP  = 20;
                    end
                else
                    if strcmp(patientsize, 'small')
                        LAT = round(rand(1)*3) + 30;
                        AP  = round(rand(1)*3) + 20;
                    elseif strcmp(patientsize, 'medium')
                        LAT = round(rand(1)*3) + 33;
                        AP  = round(rand(1)*3) + 23;
                    elseif strcmp(patientsize, 'large')
                        LAT = round(rand(1)*3) + 36;
                        AP  = round(rand(1)*3) + 26;
                    end
                    phantom = addFatRing(phantom, LAT, AP);

                end
                name1 = sprintf('Phantom_%s_%s_%s_%d_trial%d',cv,ep,patientsize,energy, j);
                save(name1,'phantom');

                % Scan and save
                I_SE = ToshibaAquilionOne(energy,exposure,phantom);
                name2 = sprintf('%s_%s_%s_%dkvp_trial%d.mat',cv,ep,patientsize,energy,j);
                save(name2,'I_SE');

                % Analysis
                if strcmp(kvps_sizes, 'energy')
                    analysis_SE = SEAnalysis( phantom, I_SE, patientsize, energy, exposure );
                    xlsappend( xlspath, analysis_SE, xlsSESheet );
                else
                    analysis_PS = PSAnalysis( phantom, I_SE, patientsize, LAT, AP, energy, exposure );
                    xlsappend( xlspath, analysis_PS, xlsSESheet );
                end
            end
        end

    end
end
