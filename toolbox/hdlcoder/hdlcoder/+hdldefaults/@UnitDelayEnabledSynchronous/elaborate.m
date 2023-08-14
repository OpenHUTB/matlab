function udComp=elaborate(this,hN,hC)





    slbh=hC.SimulinkHandle;
    initVal=this.hdlslResolve('InitialCondition',slbh);
    resetnone=false;
    rtype=this.getImplParams('ResetType');

    if~isempty(rtype)
        resetnone=strcmpi(rtype,'none');
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
    compName,initVal,resetnone,false,'',-1,true);
end


