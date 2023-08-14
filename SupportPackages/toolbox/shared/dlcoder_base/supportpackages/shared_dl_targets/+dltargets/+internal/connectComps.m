function connectComps(hDriverComp,outport,hRecvComp,inport,hN)




    if strcmpi(hDriverComp.ClassName,'dnnnetwork')
        hS=hN.addSignal;

        hS.addDriver(hDriverComp,outport);
        hSignal=hDriverComp.PirInputSignals(outport+1);
    else
        hSignal=hDriverComp.PirOutputSignals(outport+1);
        if~isa(hSignal,'gpucoder.dnnsignal')
            hS=hN.addSignal;

            hS.addDriver(hDriverComp,outport);
            hSignal=hDriverComp.PirOutputSignals(outport+1);
        end
    end

    hSignal.addReceiver(hRecvComp,inport);

end
