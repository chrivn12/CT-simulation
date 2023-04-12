f =  waitbar(0,'preparing...','Name','QRM phantom simulation');
n_vessels = 3;
r_vessels = [0.25,0.15,0.05];
m_vessels = [733,411,151;669,370,90;552,222,52]; % densities
% m_vessels = [797,101,37;403,48,32;199,41,27];
kvp = [135,80];
% phantom_size = 40;
phantom_size = [40,35,30];
c = 0;
waitbar(0,f,'generating simulation...')
for i = 1:3
    m = {['HA ',int2str(m_vessels(i,1)),'mg.ml'], ['HA ',int2str(m_vessels(i,3)),'mg.ml'],['HA ',int2str(m_vessels(i,2)),'mg.ml']}; % create mixtures
    for s = phantom_size
        p = newPhantomGene(n_vessels,r_vessels,m);
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
        I = ToshibaAquilionOne(energy,exposure,p);
        name = strcat('Density',int2str(i),'energy',int2str(energy),size);
        save(name,'I');
        c = c+1;
        waitbar(c/18,f,strcat(int2str(c),'/18 images complete'))
    end
    end
end
waitbar(1,f,'complete')
