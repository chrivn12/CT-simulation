f =  waitbar(0,'preparing...','Name','QRM phantom simulation');

% Constants
lipid_density = 0.92;
water_density = 1.00;
protein_density = 1.35;
initial_water_mass = 20.2; % g
initial_lipid_mass = 76.7; % g
initial_protein_mass = 3.1; % g
total_mass = initial_water_mass + initial_lipid_mass + initial_protein_mass;

n_vessels = 3;
r_vessels = [0.25,0.25, 0.25]; %change to all 0.25

% m_vessels = [15,18,22]; % densities
% m_vessels2 = [26,29,36];
% m_vessels3 = [52,59,73];

lipid_weight_fractions = [61; 66; 71]; %lipid weight fractions
lipid_weight_fractions2 = [73; 78; 82]; 
lipid_weight_fractions3 = [85; 89; 94];

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


% Calculate corresponding water and protein weight fractions
water_weight_fractions = (initial_water_mass ./ (total_mass - initial_lipid_mass + lipid_weight_fractions2 * total_mass / 100)) * 100;
protein_weight_fractions = (initial_protein_mass ./ (total_mass - initial_lipid_mass + lipid_weight_fractions2 * total_mass / 100)) * 100;

% Calculate volumetric fractions
water_volumetric_fractions = 100 .* water_weight_fractions ./ water_density ./ (water_weight_fractions ./ water_density + lipid_weight_fractions2 ./ lipid_density + protein_weight_fractions ./ protein_density);
lipid_volumetric_fractions = 100 .* lipid_weight_fractions2 ./ lipid_density ./ (water_weight_fractions ./ water_density + lipid_weight_fractions2 ./ lipid_density + protein_weight_fractions ./ protein_density);
protein_volumetric_fractions = 100 .* protein_weight_fractions ./ protein_density ./ (water_weight_fractions ./ water_density + lipid_weight_fractions2 ./ lipid_density + protein_weight_fractions ./ protein_density);

comparray = [water_volumetric_fractions,lipid_volumetric_fractions,protein_volumetric_fractions];
for i = 1:size(comparray,1)
    m_vessels2{i} = ['Water' num2str(comparray(i,1)) 'Lipid' num2str(comparray(i,2)) 'Protein' num2str(comparray(i,3))];
end
m_vessels2 = {m_vessels2{:}};
n_vessels2 = length(m_vessels2);


% Calculate corresponding water and protein weight fractions
water_weight_fractions = (initial_water_mass ./ (total_mass - initial_lipid_mass + lipid_weight_fractions3 * total_mass / 100)) * 100;
protein_weight_fractions = (initial_protein_mass ./ (total_mass - initial_lipid_mass + lipid_weight_fractions3 * total_mass / 100)) * 100;

% Calculate volumetric fractions
water_volumetric_fractions = 100 .* water_weight_fractions ./ water_density ./ (water_weight_fractions ./ water_density + lipid_weight_fractions3 ./ lipid_density + protein_weight_fractions ./ protein_density);
lipid_volumetric_fractions = 100 .* lipid_weight_fractions3 ./ lipid_density ./ (water_weight_fractions ./ water_density + lipid_weight_fractions3 ./ lipid_density + protein_weight_fractions ./ protein_density);
protein_volumetric_fractions = 100 .* protein_weight_fractions ./ protein_density ./ (water_weight_fractions ./ water_density + lipid_weight_fractions3 ./ lipid_density + protein_weight_fractions ./ protein_density);

comparray = [water_volumetric_fractions,lipid_volumetric_fractions,protein_volumetric_fractions];
for i = 1:size(comparray,1)
    m_vessels3{i} = ['Water' num2str(comparray(i,1)) 'Lipid' num2str(comparray(i,2)) 'Protein' num2str(comparray(i,3))];
end
m_vessels3 = {m_vessels3{:}};
n_vessels3 = length(m_vessels3);


kvp = [80, 135];
phantom_size = [30, 35, 40];

tot = length(m_vessels) * length(m_vessels2) * length(m_vessels3) * length(kvp) * length(phantom_size) * 3;
message = sprintf('/%d images complete', tot);

% run the code 3 times for 3 groups of densities
waitbar(0,f,'generating simulation...')
c = 0;
% m = {['HA ',int2str(m_vessels(1)),'mg.ml'], ['HA ',int2str(m_vessels(3)),'mg.ml'],['HA ',int2str(m_vessels(2)),'mg.ml']}; % create mixtures i think i change this
for s = phantom_size
    p = PhantomGene(n_vessels,r_vessels,m_vessels);
    p = addFatRing(p,s,s-10);
    if s == 40
        exposure = 5.4;
        psize = 'large';
    elseif s == 35
        exposure = 2.0;
        psize = 'medium';
    else
        exposure = 0.9;
        psize = 'small';
    end
    
    for energy = kvp
        name = strcat(m_vessels(1), "_", m_vessels(2),  "_", m_vessels(3),'energy',int2str(energy),psize);

        % generate 3 same images to simulate the differing noise for each slice.
        I = ToshibaAquilionOne(energy,exposure,p);
        save(strcat("val\", name, "_1"), "I");
        c = c+1;
        waitbar(c/tot,f,strcat(int2str(c),message))

        I = ToshibaAquilionOne(energy,exposure,p);
        save(strcat("val\", name, "_2"), "I");
        c = c+1;
        waitbar(c/tot,f,strcat(int2str(c),message))

        I = ToshibaAquilionOne(energy,exposure,p);
        save(strcat("val\", name, "_3"), "I");
        c = c+1;
        waitbar(c/tot,f,strcat(int2str(c),message))
    end
end





% m = {['HA ',int2str(m_vessels2(1)),'mg.ml'], ['HA ',int2str(m_vessels2(3)),'mg.ml'],['HA ',int2str(m_vessels2(2)),'mg.ml']}; % create mixtures
for s = phantom_size
    p = PhantomGene(n_vessels2,r_vessels,m_vessels2);
    p = addFatRing(p,s,s-10);
    if s == 40
        exposure = 5.4;
        psize = 'large';
    elseif s == 35
        exposure = 2.0;
        psize = 'medium';
    else
        exposure = 0.9;
        psize = 'small';
    end
    
    for energy = kvp
        name = strcat(m_vessels2(1), "_", m_vessels2(2),  "_", m_vessels2(3),'energy',int2str(energy),psize);

        % generate 3 same images to simulate the differing noise for each slice.
        I = ToshibaAquilionOne(energy,exposure,p);
        save(strcat("val\", name, "_1"), "I");
        c = c+1;
        waitbar(c/tot,f,strcat(int2str(c),message))

        I = ToshibaAquilionOne(energy,exposure,p);
        save(strcat("val\", name, "_2"), "I");
        c = c+1;
        waitbar(c/tot,f,strcat(int2str(c),message))

        I = ToshibaAquilionOne(energy,exposure,p);
        save(strcat("val\", name, "_3"), "I");
        c = c+1;
        waitbar(c/tot,f,strcat(int2str(c),message))
    end
end




% m = {['HA ',int2str(m_vessels3(1)),'mg.ml'], ['HA ',int2str(m_vessels3(3)),'mg.ml'],['HA ',int2str(m_vessels3(2)),'mg.ml']}; % create mixtures
for s = phantom_size
    p = PhantomGene(n_vessels3,r_vessels,m_vessels3);
    p = addFatRing(p,s,s-10);
    if s == 40
        exposure = 5.4;
        psize = 'large';
    elseif s == 35
        exposure = 2.0;
        psize = 'medium';
    else
        exposure = 0.9;
        psize = 'small';
    end
    
    for energy = kvp
        name = strcat(m_vessels3(1), "_", m_vessels3(2),  "_", m_vessels3(3),'energy',int2str(energy),psize);

        % generate 3 same images to simulate the differing noise for each slice.
        I = ToshibaAquilionOne(energy,exposure,p);
        save(strcat("val\", name, "_1"), "I");
        c = c+1;
        waitbar(c/tot,f,strcat(int2str(c),message))

        I = ToshibaAquilionOne(energy,exposure,p);
        save(strcat("val\", name, "_2"), "I");
        c = c+1;
        waitbar(c/tot,f,strcat(int2str(c),message))

        I = ToshibaAquilionOne(energy,exposure,p);
        save(strcat("val\", name, "_3"), "I");
        c = c+1;
        waitbar(c/tot,f,strcat(int2str(c),message))
    end
end

waitbar(1,f,'complete')