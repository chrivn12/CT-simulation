f =  waitbar(0,'preparing...','Name','calibration phantom simulation');
kVp = [80, 135];
m_vessels = [10, 16, 25, 45, 50, 75 , 100, 200, 300, 400, 500, 600, 800];
size = [30];
tot = length(m_vessels) * 3 * 2;
message = sprintf('/%d images complete', tot);

c = 0;
waitbar(0,f,'generating calibration phantom simulation...')
for i = 1:numel(m_vessels)
    m = ['HA ',int2str(m_vessels(i)),'mg.ml'];
    rod = rodGene(1, m);
    rod = addFatRing(rod,size,size-10);
    exposure = 40;
    for energy = kVp
        name = strcat(int2str(m_vessels(i)),'rod',int2str(energy),'kV',int2str(size));

        I = ToshibaAquilionOne(energy,exposure,rod);
        save(strcat("cal\",name, '_1'), "I");
        c = c+1;
        waitbar(c/tot,f,strcat(int2str(c),message))

        I = ToshibaAquilionOne(energy,exposure,rod);
        save(strcat("cal\",name, '_2'), "I");
        c = c+1;
        waitbar(c/tot,f,strcat(int2str(c),message))

        I = ToshibaAquilionOne(energy,exposure,rod);
        save(strcat("cal\",name, '_3'), "I");
        c = c+1;
        waitbar(c/tot,f,strcat(int2str(c),message))
    end
end
waitbar(1,f,'complete')
