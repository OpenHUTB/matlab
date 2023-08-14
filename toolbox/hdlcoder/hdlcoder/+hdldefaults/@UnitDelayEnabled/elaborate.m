function udComp=elaborate(this,hN,hC)


    slbh=hC.SimulinkHandle;
    initval=this.hdlslResolve('vinit',slbh);

    resetnone=false;
    rtype=this.getImplParams('ResetType');
    if~isempty(rtype)
        resetnone=~isempty(strmatch(lower(rtype),'none'));
    end

    compName=hC.Name;
    hOutSignals=hC.SLOutputSignals;
    hDataIn=hC.SLInputSignals(1);
    hEnableIn=hC.SLInputSignals(2);

    [outdimlen,~]=pirelab.getVectorTypeInfo(hOutSignals(1));
    [indimlen,~]=pirelab.getVectorTypeInfo(hDataIn);

    if(any(outdimlen>1)&&all(indimlen==1))

        hMuxOut=pirelab.scalarExpand(hN,hDataIn,outdimlen);
        hDataIn=hMuxOut;
    end

    udComp=pirelab.getUnitDelayEnabledComp(hN,hDataIn,hOutSignals,hEnableIn,...
    compName,initval,resetnone,false);
end
