f =  waitbar(0,'preparing...','Name','calibration phantom simulation');
kVp = [135,80];
% mat = {'HA 800mg.ml','HA 400mg.ml','HA 200mg.ml','HA 100mg.ml','HA 50mg.ml','HA 25mg.ml'};
m_vessels = [50,100,150,200,250,300,350,400,450,500,550,600,650,750,800];
% m_vessels = 25;
size = [30,35,40];
c = 0;
waitbar(0,f,'generating calibration phantom simulation...')
for i = 1:numel(m_vessels)
    m = ['HA ',int2str(m_vessels(i)),'mg.ml'];
    for LAT = size
        rod = rodGene(1, m);
        rod = addFatRing(rod,LAT,LAT-10);
        if LAT == 35
            exposure = 25;
        elseif LAT == 40
            exposure = 54;
        else
            exposure = 10;
        end
        for energy = kVp
            I = ToshibaAquilionOne(energy,exposure,rod);
            name = strcat(int2str(m_vessels(i)),'rod',int2str(energy),'kV',int2str(LAT));
            save(name,'I')
            c = c+1;
            waitbar(c/32,f,strcat(int2str(c),'/32 images complete'))
        end
    end
end
waitbar(1,f,'complete')
