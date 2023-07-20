function[children,breakPointIndex]=getSFBreakpointRows(modelName,breakPointIndex,srcToBeHighlighted)



    children=[];
    if~sf('feature','SlDebuggerIntegration')
        return;
    end

    rt=sfroot;
    machineH=rt.find('-isa','Stateflow.Machine','Name',modelName);
    if~isa(machineH,'Stateflow.Machine')
        mrfs=find_mdlrefs(modelName);
        for i=1:numel(mrfs)
            if~bdIsLoaded(mrfs{1})||strcmp(mrfs{i},modelName)
                continue;
            end
            machineH=rt.find('-isa','Stateflow.Machine','Name',mrfs{i});
            if~isa(machineH,'Stateflow.Machine')
                continue;
            end
            [rows,breakPointIndex]=SimulinkDebugger.breakpoints.getSFBreakpointRows(machineH.Name,breakPointIndex,srcToBeHighlighted);
            children=[children,rows];%#ok<AGROW>
        end
        return;
    end
    [children,breakPointIndex]=constructRows(machineH,breakPointIndex,srcToBeHighlighted);
    [bpRows,breakPointIndex]=getBreakPointRowsInLinkedAtomicSubcharts(machineH,breakPointIndex,srcToBeHighlighted);
    children=[children,bpRows];
    children=unique(children);
end

function[slBPRows,breakPointIndex]=getBreakPointRowsInLinkedAtomicSubcharts(machineH,breakPointIndex,srcToBeHighlighted)









    slBPRows=[];
    isSeen=[];
    linkedCharts=machineH.find('-isa','Stateflow.LinkChart');
    for linkedChart=linkedCharts'
        if linkedChart.Machine.Id~=machineH.Id
            continue;
        end
        blkH=sf('get',linkedChart.Id,'.handle');
        chartId=sfprivate('block2chart',blkH);
        chartObj=sf('IdToHandle',chartId);
        libMachine=chartObj.Machine;
        if~isempty(find(isSeen==libMachine.Id,1))
            continue;
        end
        isSeen=[isSeen,libMachine.Id];%#ok<AGROW>
        [rows,breakPointIndex]=SimulinkDebugger.breakpoints.getSFBreakpointRows(libMachine.Name,breakPointIndex,srcToBeHighlighted);
        slBPRows=[slBPRows,rows];%#ok<AGROW>
    end
end

function[slBPRows,breakPointIndex]=constructRows(machineH,breakPointIndex,srcToBeHighlighted)
    slBPRows=[];
    supportedTypes={'Stateflow.Chart',...
    'Stateflow.State',...
    'Stateflow.Transition',...
    'Stateflow.SimulinkBasedState',...
    'Stateflow.Function',...
    'Stateflow.AtomicSubchart',...
    'Stateflow.TruthTable'};
    if~isempty(srcToBeHighlighted)...
        &&(isa(srcToBeHighlighted,'Stateflow.Debug.SFBreakpoint')...
        ||isa(srcToBeHighlighted,'Stateflow.Debug.EML.EMLBreakpoint'))
        hitBpId=srcToBeHighlighted.id;
    else
        hitBpId=-1;
    end
    for i=1:numel(supportedTypes)
        type=supportedTypes{i};
        [rows,breakPointIndex]=getBreakPointRows_helper(machineH,breakPointIndex,type,hitBpId);
        slBPRows=[slBPRows,rows];%#ok<AGROW>
    end
    [emlRows,breakPointIndex]=constructEMLRows(machineH,breakPointIndex,hitBpId);
    slBPRows=[slBPRows,emlRows];
end

function[slBPRows,breakPointIndex]=getBreakPointRows_helper(machineH,breakPointIndex,objType,hitBpId)
    slBPRows=[];
    objectHandles=machineH.find('-isa',objType);
    for objH=objectHandles'
        breakPointList=Stateflow.Debug.get_breakpoints_for(objH);
        for i=1:numel(breakPointList)
            sfbp=breakPointList{i};
            isHit=(sfbp.id==hitBpId)&&sfbp.isEnabled;
            slbp=SimulinkDebugger.breakpoints.SFBreakPoint(breakPointIndex,sfbp.id,sfbp.cachedOwnerPath,convertSfToSLEnum(sfbp.tagEnum,objType),sfbp.numHits,sfbp.condition,sfbp.isEnabled,objType,isHit);
            slbpRow=SimulinkDebugger.breakpoints.BreakpointListSpreadsheetSFRow(slbp);
            slBPRows=[slBPRows,slbpRow];%#ok<AGROW>
            breakPointIndex=breakPointIndex+1;
        end
    end

    function slEnum=convertSfToSLEnum(sfEnum,objType)
        switch sfEnum
        case Stateflow.Debug.BreakpointTypeEnums.onStateEntry
            slEnum=SimulinkDebugger.breakpoints.BreakpointType.onStateEntry;
        case Stateflow.Debug.BreakpointTypeEnums.onStateDuring
            if strcmp(objType,'Stateflow.Function')||strcmp(objType,'Stateflow.TruthTable')
                slEnum=SimulinkDebugger.breakpoints.BreakpointType.onFunctionDuringCall;
            else
                slEnum=SimulinkDebugger.breakpoints.BreakpointType.onStateDuring;
            end
        case Stateflow.Debug.BreakpointTypeEnums.onStateExit
            slEnum=SimulinkDebugger.breakpoints.BreakpointType.onStateExit;
        case Stateflow.Debug.BreakpointTypeEnums.whenTransitionTested
            slEnum=SimulinkDebugger.breakpoints.BreakpointType.whenTransitionTested;
        case Stateflow.Debug.BreakpointTypeEnums.whenTransitionValid
            slEnum=SimulinkDebugger.breakpoints.BreakpointType.whenTransitionValid;
        case Stateflow.Debug.BreakpointTypeEnums.onChartEntry
            slEnum=SimulinkDebugger.breakpoints.BreakpointType.onChartEntry;
        end
    end
end

function[slBPRows,breakPointIndex]=constructEMLRows(machineH,breakPointIndex,hitBpId)
    objectHandles=machineH.find('-isa','Stateflow.EMChart');
    type=SimulinkDebugger.breakpoints.BreakpointType.EMChart;
    [emChartBPRows,breakPointIndex]=constructEMLRows_helper(objectHandles,type,breakPointIndex,hitBpId);
    objectHandles=machineH.find('-isa','Stateflow.EMFunction');
    type=SimulinkDebugger.breakpoints.BreakpointType.EMFunction;
    [emFunctionBPRows,breakPointIndex]=constructEMLRows_helper(objectHandles,type,breakPointIndex,hitBpId);
    slBPRows=[emChartBPRows,emFunctionBPRows];
end

function[slBPRows,breakPointIndex]=constructEMLRows_helper(objectHandles,type,breakPointIndex,hitBpId)
    slBPRows=[];
    for objH=objectHandles'
        breakPointList=Stateflow.Debug.EML.getEMLBreakpointsFor(objH);
        for i=1:numel(breakPointList)
            sfbp=breakPointList{i};
            objPath=objH.Path;
            splitPath=strsplit(objPath,'/');
            bpPath=[splitPath{1},'/.../',splitPath{end},':',num2str(sfbp.lineNum)];
            isHit=(sfbp.id==hitBpId)&&sfbp.isEnabled;
            slbp=SimulinkDebugger.breakpoints.EMLBreakPoint(breakPointIndex,sfbp.id,type,bpPath,sfbp.lineNum,sfbp.numHits,sfbp.condition,sfbp.isEnabled,isHit);
            slbpRow=SimulinkDebugger.breakpoints.BreakpointListSpreadsheetSFRow(slbp);
            slBPRows=[slBPRows,slbpRow];%#ok<AGROW>
            breakPointIndex=breakPointIndex+1;
        end
    end
end