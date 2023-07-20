function delayComp=getUnitDelayResettableComp(hN,hInSignals,hOutSignals,hRstSignals,compName,ic,resettype,softreset,desc,slHandle)




    if(nargin<10)
        slHandle=-1;
    end

    if(nargin<9)
        desc='';
    end

    if(nargin<8)
        softreset=false;
    end

    if(nargin<7)
        resettype='';
    end

    if(nargin<6)
        ic='';
    end

    if(nargin<5)
        compName='reg';
    end


    if(isempty(ic))
        ic=pirelab.getTypeInfoAsFi(hInSignals.Type);
    else
        ic=pirelab.getTypeInfoAsFi(hInSignals.Type,'Floor','Wrap',ic);
    end

    resetnone=false;
    if~isempty(resettype)
        resetnone=resettype;
    end




    hRstSignals=pireml.getCompareToZero(hN,hRstSignals(1),'~=',sprintf('%s_enable',compName),sprintf('%s_not0',compName));

    [rstDims,~]=pirelab.getVectorTypeInfo(hRstSignals);
    [~,outType]=pirelab.getVectorTypeInfo(hOutSignals);

    if rstDims==1
        delayComp=createUDEComp(hN,hInSignals,hOutSignals,hRstSignals,ic,resetnone,compName,desc,softreset,slHandle);
    else
        hDelayOutSignals=hdlhandles(rstDims,1);
        hDataDemux=pirelab.getDemuxCompOnInput(hN,hInSignals);
        hEnbDemux=pirelab.getDemuxCompOnInput(hN,hRstSignals);
        for ii=1:rstDims
            hDelayOutSignals(ii)=hN.addSignal(outType,sprintf('%s_delay%d',compName,ii));
            delayComp=createUDEComp(hN,hDataDemux.PirOutputSignals(ii),hRstSignals.PirOutputSignals(ii),hDelayOutSignals(ii),ic(ii),resetnone,sprintf('%s_%d',compName,ii),desc,softreset,slHandle);
        end
        hMux=pirelab.getMuxComp(hN,hDelayOutSignals,hOutSignals,sprintf('%s_concat',compName));
    end

end

function delayComp=createUDEComp(hN,hInSignals,hOutSignals,hRstSignal,ic,resetnone,compName,desc,softreset,slHandle)

    [clock,clkEnb,reset]=hN.getClockBundle(hInSignals(1),1,1,0);

    if(softreset)

        ipf='hdleml_delay';

        delayComp=hN.addComponent2(...
        'kind','cgireml',...
        'Name',compName,...
        'SimulinkHandle',slHandle,...
        'InputSignals',[hInSignals],...
        'OutputSignals',hOutSignals,...
        'EnableSignals',clkEnb,...
        'ExternalSynchronousResetSignal',hRstSignal,...
        'EMLFileName',ipf,...
        'EMLParams',{ic},...
        'EMLFlag_RunLoopUnrolling',false,...
        'EMLFlag_ConditionalStmtInProcess',true,...
        'BlockComment',desc);


    else
        ipf='hdleml_delay_resettable_classic';

        delayComp=hN.addComponent2(...
        'kind','cgireml',...
        'Name',compName,...
        'SimulinkHandle',slHandle,...
        'InputSignals',[hInSignals,hRstSignal],...
        'OutputSignals',hOutSignals,...
        'EnableSignals',clkEnb,...
        'ExternalSynchronousResetSignal',hRstSignal,...
        'EMLFileName',ipf,...
        'EMLParams',{ic},...
        'EMLFlag_RunLoopUnrolling',false,...
        'EMLFlag_ConditionalStmtInProcess',true,...
        'BlockComment',desc);
    end


    delayComp.connectClockBundle(clock,clkEnb,reset);

    delayComp.resetNone(resetnone);

    if targetmapping.isValidDataType(hInSignals(1).Type)
        delayComp.setSupportTargetCodGenWithoutMapping(true);
    end

end


