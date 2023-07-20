function hNewC=baseSFElaborate(this,hN,hC)










    [chartId,machine,isSFChart,isInitOutput,...
    generateResetLogic,...
    concurrencyMaximization,retiming,...
    constMultMode,ramMapping,guardIndex,simIndexCheck,...
    loopOptimization,persistentWarning,...
    variablePipeline,sharingFactor,instantiateFcns,...
    matrixTypes,hasInputEvents,compactSwitch]=this.getBlockInfo(hC);

    hdlcoder=hdlcurrentdriver;
    shandle=hC.SimulinkHandle;



    if hdlcoder.DUTMdlRefHandle>0
        snnH=get_param(hdlcoder.OrigStartNodeName,'handle');
        if isprop(snnH,'BlockType')&&~strcmp(get_param(snnH,'BlockType'),'ModelReference')
            obj=get_param(shandle,'Object');
            origFullPath=regexprep(obj.getFullName,hdlcoder.ModelName,hdlcoder.OrigStartNodeName,'once');
            shandle=get_param(origFullPath,'handle');
        end
    end


    annotations=find(idToHandle(sfroot,chartId),'-isa','Stateflow.Annotation');
    if~isempty(annotations)
        all_comments_in_the_chart=strjoin(arrayfun(@(x)x.PlainText,annotations,'UniformOut',false),newline);
        hN.addComment(all_comments_in_the_chart);
    end

    [TunableParamStrs,TunableParamTypes,TunableDataIds]=getTunableProperty(this,hC.SimulinkHandle);


    sf('set',chartId,'chart.hdlInfo.rtwSubsystemId',getSysId(shandle));
    sf('set',chartId,'chart.hdlInfo.HDLTraceability',hdlgetparameter('TraceabilityProcessing'));
    sf('set',chartId,'chart.hdlInfo.emitRequirementComments',hdlgetparameter('emitRequirementComments'));
    sf('set',chartId,'chart.hdlInfo.tunableDataIds',TunableDataIds);

    hC.Name=getEntityName(hC.Name,hC.SimulinkHandle);

    hNewC=hN.addComponent2(...
    'kind','sf_comp',...
    'name',hC.Name,...
    'InputSignals',hC.PirInputSignals,...
    'OutputSignals',hC.PirOutputSignals,...
    'ChartID',hC.SimulinkHandle,...
    'Machine',machine,...
    'StateflowChart',isSFChart,...
    'InitOutput',isInitOutput,...
    'GenerateResetLogic',generateResetLogic,...
    'Retiming',retiming,...
    'ConstMultMode',constMultMode,...
    'RamMapping',ramMapping,...
    'GuardIndexVariables',guardIndex,...
    'VariablePipeline',variablePipeline,...
    'SharingFactor',sharingFactor,...
    'InstantiateFunctions',instantiateFcns,...
    'MatrixTypes',matrixTypes,...
    'TunableParamStrs',TunableParamStrs,...
    'CompactSwitch',compactSwitch,...
    'SimIndexCheck',simIndexCheck);
    hNewC.SimulinkHandle=hC.SimulinkHandle;
    hNewC.setHasInputEvents(hasInputEvents);


    if isSFChart
        chartH=idToHandle(sfroot,chartId);
        chartType=chartH.stateMachineType;


        this.setChartType(hNewC,chartType);


        if strcmp(hdlfeature('EnableClockDrivenOutput'),'on')...
            &&strcmp(chartType,'Moore')...
            &&strcmp(getImplParams(this,'ClockDrivenOutput'),'on')

            hNewC.setClockDrivenOutput(true);
        end
    end

    if strcmp(hdlfeature('EnableFlattenSFComp'),'on')



        if hN.getFlattenSFHolderNetwork
            if~isempty(hC.PirInputPorts)&&~strcmp(hC.PirInputPorts(end).Kind,'data')
                hN.setFlattenSFHolderNetwork(false);
            else
                hNewC.copyComment(hC);
            end
        end
    else
        if hdlgetparameter('inlinematlabblockcode')
            hNewC.copyComment(hC);
        end
    end

    if~isempty(TunableParamStrs)
        hNewC.setTunableParamTypes(TunableParamTypes);
    end
    loopUnrolling=strcmpi(loopOptimization,'Unrolling');
    loopStreaming=strcmpi(loopOptimization,'Streaming');
    hNewC.runLoopUnrolling(loopUnrolling);
    hNewC.runLoopStreaming(loopStreaming);


    totalOuts=length(hNewC.PirOutputPorts);
    for ii=1:totalOuts
        hNewC.PirOutputPorts(ii).copySLDataFrom(hC.PirOutputPorts(ii));
    end
    for ii=1:length(hNewC.PirInputPorts)
        hNewC.PirInputPorts(ii).copySLDataFrom(hC.PirInputPorts(ii));
    end

    hNewC.resetNone(~generateResetLogic);
    hNewC.runConcurrencyMaximizer(concurrencyMaximization);
    hNewC.emitPersistentWarning(persistentWarning);


    hNewC.runWebRenaming(true);
    hNewC.createCGIR();
end



function setChartType(~,hNewC,chartType)

    switch chartType
    case 'Moore'
        hNewC.setIsMooreChart;
    case 'Mealy'
        hNewC.setIsMealyChart;
    case 'Classic'
        hNewC.setIsClassicChart;
    otherwise
        hNewC.setIsNotAChart;
    end
end

function id=getSysId(handle)
    sess=Simulink.CMI.EIAdapter(Simulink.EngineInterfaceVal.byFiat);
    id=getSystemNumber(get_param(handle,'object'));
    delete(sess);
end

function codegenEntityName=getEntityName(entityName,chartHandle)
    chartID=sfprivate('block2chart',chartHandle);
    r=sfroot;
    chartUddH=r.idToHandle(chartID);

    if chartUddH.machine.IsLibrary
        codegenEntityName=getSafeLibChartName(chartID,chartHandle);
    else
        codegenEntityName=entityName;
    end
end


function safeName=getSafeLibChartName(chart,chartHandle)
    maxLength=namelengthmax;
    machine=sf('get',chart,'chart.machine');
    chartFileNumber=sf('get',chart,'chart.chartFileNumber');
    modelName=sf('get',machine,'machine.name');
    blockH=sfprivate('chart2block',chart);
    blockName=regexprep(get_param(blockH,'name'),'[^\w]','_');

    specs=sf('Cg','get_module_specializations',chart);
    if length(specs)>1
        mainMachineName=get_param(bdroot(chartHandle),'Name');
        sf('SelectChartIDCInfoByMachine',chart,mainMachineName);
        specStr=sf('SFunctionSpecialization',chart,chartHandle);
        safeName=sprintf('%s_c%d_%s',modelName,chartFileNumber,specStr);
    else
        safeName=sprintf('%s_c%d',modelName,chartFileNumber);
    end

    if(length(safeName)<maxLength)
        safeName=[safeName,'_',blockName];
        if(length(safeName)>maxLength)
            safeName=safeName(1:maxLength);
        end
    end
end


