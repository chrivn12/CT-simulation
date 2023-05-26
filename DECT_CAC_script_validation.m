f =  waitbar(0,'preparing...','Name','QRM phantom simulation');
n_vessels = 3;
r_vessels = [0.25,0.15,0.05];
m_vessels = [15,18,22]; % densities
m_vessels2 = [26,29,36];
m_vessels3 = [52,59,73];
kvp = [80, 135];
phantom_size = [30, 35, 40];

tot = length(m_vessels) * length(m_vessels2) * length(m_vessels3) * length(kvp) * length(phantom_size) * 3;
message = sprintf('/%d images complete', tot);

% run the code 3 times for 3 groups of densities
waitbar(0,f,'generating simulation...')
c = 0;
m = {['HA ',int2str(m_vessels(1)),'mg.ml'], ['HA ',int2str(m_vessels(3)),'mg.ml'],['HA ',int2str(m_vessels(2)),'mg.ml']}; % create mixtures
for s = phantom_size
    p = PhantomGene(n_vessels,r_vessels,m);
    p = addFatRing(p,s,s-10);
    if s == 40
        exposure = 5.4;
        size = 'large';
    elseif s == 35
        exposure = 2.0;
        size = 'medium';
    else
        exposure = 0.9;
        size = 'small';
    end
    
    for energy = kvp
        name = strcat(int2str(m_vessels(1)), "_", int2str(m_vessels(2)),  "_", int2str(m_vessels(3)),'energy',int2str(energy),size);

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





m = {['HA ',int2str(m_vessels2(1)),'mg.ml'], ['HA ',int2str(m_vessels2(3)),'mg.ml'],['HA ',int2str(m_vessels2(2)),'mg.ml']}; % create mixtures
for s = phantom_size
    p = PhantomGene(n_vessels,r_vessels,m);
    p = addFatRing(p,s,s-10);
    if s == 40
        exposure = 5.4;
        size = 'large';
    elseif s == 35
        exposure = 2.0;
        size = 'medium';
    else
        exposure = 0.9;
        size = 'small';
    end
    
    for energy = kvp
        name = strcat(int2str(m_vessels2(1)), "_", int2str(m_vessels2(2)),  "_", int2str(m_vessels2(3)),'energy',int2str(energy),size);

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




m = {['HA ',int2str(m_vessels3(1)),'mg.ml'], ['HA ',int2str(m_vessels3(3)),'mg.ml'],['HA ',int2str(m_vessels3(2)),'mg.ml']}; % create mixtures
for s = phantom_size
    p = PhantomGene(n_vessels,r_vessels,m);
    p = addFatRing(p,s,s-10);
    if s == 40
        exposure = 5.4;
        size = 'large';
    elseif s == 35
        exposure = 2.0;
        size = 'medium';
    else
        exposure = 0.9;
        size = 'small';
    end
    
    for energy = kvp
        name = strcat(int2str(m_vessels3(1)), "_", int2str(m_vessels3(2)),  "_", int2str(m_vessels3(3)),'energy',int2str(energy),size);

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