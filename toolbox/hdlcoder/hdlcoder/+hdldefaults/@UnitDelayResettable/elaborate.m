function hNewC=elaborate(this,hN,hC)


    slbh=hC.SimulinkHandle;
    initval=this.hdlslResolve('vinit',slbh);

    resetnone=false;
    rtype=this.getImplParams('ResetType');
    if~isempty(rtype)
        resetnone=~isempty(strcmpi(rtype,'none'));
    end

    syncType=this.getImplParams('softreset');
    if(isempty(syncType))
        softreset=false;
    elseif(strcmpi(syncType,'off'))
        softreset=false;
    elseif(strcmpi(syncType,'on'))
        softreset=true;
    else
        error(message('hdlcoder:validate:InvalidSoftreset'));

    end

    compName=hC.Name;
    hOutSignals=hC.PirOutputSignals;
    hDataIn=hC.PirInputSignals(1);
    hRstIn=hC.PirInputSignals(2);

    [outdimlen,~]=pirelab.getVectorTypeInfo(hOutSignals(1));
    [indimlen,~]=pirelab.getVectorTypeInfo(hDataIn);

    if(any(outdimlen>1)&&all(indimlen==1))

        hMuxOut=pirelab.scalarExpand(hN,hDataIn,outdimlen);
        hDataIn=hMuxOut;
    end


    hNewC=pirelab.getUnitDelayResettableComp(hN,hDataIn,hOutSignals,hRstIn,...
    compName,initval,resetnone,softreset,'');
end


