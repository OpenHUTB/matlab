function annotatePIR(p)




    narginchk(1,1);
    vNtwks=p.Networks;
    for ii=1:length(vNtwks)
        vSignals=vNtwks(ii).Signals;
        for jj=1:length(vSignals)
            hS=vSignals(jj);
            hS.VType(pirgetvtype(hS));
            hS.Forward([]);
            hS.Imag([]);
        end
    end
end
