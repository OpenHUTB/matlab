function udComp=elaborate(this,hN,hC)


    slbh=hC.SimulinkHandle;
    initval=hdlslResolve('InitialCondition',slbh);
    rtype=this.getImplParams('ResetType');
    if~isempty(rtype)&&strncmpi(rtype,'none',4)
        resetnone=true;
    else
        resetnone=false;
    end

    hInSignals=hC.SLInputSignals;
    hOutSignals=hC.SLOutputSignals;

    compName=hC.Name;
    if(hOutSignals(1).Type.isArrayType&&~hInSignals(1).Type.isArrayType)

        hMuxOut=hN.addSignal(hOutSignals(1));
        hMuxOut.Name=sprintf('%s_scalarexpand',compName);
        outdimlen=pirelab.getVectorTypeInfo(hOutSignals(1));
        assert(numel(outdimlen)==1,'unexpected scalar input with matrix output')
        hMuxInSignals=repmat(hInSignals(1),1,outdimlen);
        hMux=pirelab.getMuxComp(hN,hMuxInSignals,hMuxOut);%#ok<*NASGU>
        hInSignals=hMuxOut;
    end

    udComp=pirelab.getUnitDelayComp(hN,hInSignals,hOutSignals,compName,...
    initval,resetnone);
    if hdlgetparameter('preserveDesignDelays')==1
        if(udComp.isDelay)
            udComp.setDoNotDistribute(1);
        end
    end
end
