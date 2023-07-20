function delayComp=getUnitDelayEnabledComp(hN,hInSignals,hOutSignals,...
    hEnbSignals,compName,ic,resettype,desc,slHandle)



    narginchk(6,9);
    if nargin<9
        slHandle=-1;
    end

    if nargin<8
        desc='';
    end

    if nargin<7
        resettype='';
    end

    if(isempty(ic))
        ic=pirelab.getTypeInfoAsFi(hInSignals.Type);
    else
        ic=pirelab.getTypeInfoAsFi(hInSignals.Type,'Nearest','Saturate',ic);
        ic=pirelab.getTypeInfoAsFi(hInSignals.Type,'Floor','Wrap',ic);
    end

    if~isempty(resettype)
        resetnone=resettype;
    else
        resetnone=false;
    end



    if isinf(hInSignals.SimulinkRate)
        rateSig=hEnbSignals(1);
    else
        rateSig=hInSignals;
    end
    [~,clkEnb,~]=hN.getClockBundle(rateSig,1,1,0);

    hEnbSignals=pireml.getCompareToZero(hN,hEnbSignals(1),'~=',...
    sprintf('%s_enable',compName),sprintf('%s_not0',compName));

    [enbDims,~]=pirelab.getVectorTypeInfo(hEnbSignals);
    [~,outType]=pirelab.getVectorTypeInfo(hOutSignals);

    if enbDims==1
        delayComp=createUDEComp(hN,hInSignals,hEnbSignals,clkEnb,hOutSignals,...
        ic,resetnone,compName,desc,slHandle);
    else
        hDelayOutSignals=hdlhandles(enbDims,1);
        hDataDemux=pirelab.getDemuxCompOnInput(hN,hInSignals);
        hEnbDemux=pirelab.getDemuxCompOnInput(hN,hEnbSignals);
        for ii=1:enbDims
            hDelayOutSignals(ii)=hN.addSignal(outType,...
            sprintf('%s_delay%d',compName,ii));
            delayComp=createUDEComp(hN,hDataDemux.PirOutputSignals(ii),...
            hEnbDemux.PirOutputSignals(ii),clkEnb,hDelayOutSignals(ii),ic(ii),...
            resetnone,sprintf('%s_%d',compName,ii),desc,slHandle);
        end
        hMux=pirelab.getMuxComp(hN,hDelayOutSignals,hOutSignals,...
        sprintf('%s_concat',compName));%#ok<NASGU>
    end

end

function delayComp=createUDEComp(hN,hInSignals,enableSignal,clkEnb,...
    hOutSignals,ic,resetnone,compName,desc,slHandle)
    [clock,~,reset]=hN.getClockBundle(clkEnb,1,1,0);

    delayComp=hN.addComponent2(...
    'kind','cgireml',...
    'Name',compName,...
    'SimulinkHandle',slHandle,...
    'InputSignals',hInSignals,...
    'OutputSignals',hOutSignals,...
    'EnableSignals',clkEnb,...
    'ExternalEnableSignal',enableSignal,...
    'EMLFileName','hdleml_delay',...
    'EMLParams',{ic},...
    'EMLFlag_RunLoopUnrolling',false,...
    'BlockComment',desc);

    delayComp.connectClockBundle(clock,clkEnb,reset);
    delayComp.resetNone(resetnone);

    if targetmapping.isValidDataType(hInSignals(1).Type)
        delayComp.setSupportTargetCodGenWithoutMapping(true);
    end
end
