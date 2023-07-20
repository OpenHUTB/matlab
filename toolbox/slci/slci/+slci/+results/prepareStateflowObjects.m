

function[keyList,keyToHandle]=prepareStateflowObjects(Config,sfBlocks,...
    keyToHandle,mfModel)
    assert(nargin==3||nargin==4);



    isResultsMF=(nargin==4);
    if isResultsMF
        reader=Config;
    else
        mdl=Config.getModelName();
        datamgr=Config.getDataManager(mdl);
        reader=datamgr.getBlockReader();
    end
    keyList=cell(numel(sfBlocks),1);
    for k=1:numel(sfBlocks)
        blkH=sfBlocks(k);
        chartId=sfprivate('block2chart',blkH);
        chartUDDObj=idToHandle(sfroot,chartId);



        if Stateflow.SLUtils.isChildOfStateflowBlock(blkH)
            continue;
        end

        blkObj=get_param(blkH,'Object');
        if strcmpi(blkObj.CompiledIsActive,'off')

            continue;
        end


        if isResultsMF
            slciChartObj=createChartObj(chartUDDObj,blkH,mfModel);
            slciChartObj.isRootChart=true;
            subComponents=prepareComponents(chartUDDObj,slciChartObj,...
            blkH,reader,mfModel);
        else
            slciChartObj=createChartObj(chartUDDObj,blkH);
            slciChartObj.setIsRootChart(true);
            subComponents=prepareComponents(chartUDDObj,slciChartObj,...
            blkH,reader);
        end
        if~isempty(subComponents)
            slciChartObj.setComponents(subComponents);
        end

        parentBlk=get_param(slciChartObj.getSID(),'Parent');
        if strcmpi(get_param(parentBlk,'type'),'block')
            parentKey=slci.results.getKeyFromBlockHandle(parentBlk);
            if isResultsMF
                slciChartObj.parent=parentKey;
            else
                parentObj=reader.getObject(parentKey);
                slciChartObj.setParent(parentObj);
            end
        end

        if isResultsMF
            keyList{k,1}=slciChartObj.key;
            keyToHandle(slciChartObj.key)=blkH;

            reader.insertObject(slciChartObj);
        else
            keyList{k,1}=slciChartObj.getKey();
            keyToHandle(slciChartObj.getKey())=blkH;

            reader.insertObject(slciChartObj.getKey(),slciChartObj);
        end
    end


    keyList=keyList(~cellfun(@isempty,keyList));

end

function subComponents=prepareComponents(sfObj,slciObj,...
    parentChartHdl,reader,mfModel)
    isResultsMF=(nargin==5);
    if isResultsMF

        subCharts=prepareSubcharts(sfObj,slciObj,reader,mfModel);


        states=prepareStates(sfObj,slciObj,parentChartHdl,reader,mfModel);


        transitions=prepareTransitions(sfObj,slciObj,parentChartHdl,reader,mfModel);


        boxComponents=prepareBoxComponents(sfObj,slciObj,parentChartHdl,reader,mfModel);


        gfComponents=prepareGraphicalFunctionComponents(sfObj,slciObj,parentChartHdl,...
        reader,mfModel);


        tblComponents=prepareTruthTableComponents(sfObj,slciObj,parentChartHdl,...
        reader,mfModel);
    else

        subCharts=prepareSubcharts(sfObj,slciObj,reader);


        states=prepareStates(sfObj,slciObj,parentChartHdl,reader);


        transitions=prepareTransitions(sfObj,slciObj,parentChartHdl,reader);


        boxComponents=prepareBoxComponents(sfObj,slciObj,parentChartHdl,reader);


        gfComponents=prepareGraphicalFunctionComponents(sfObj,slciObj,parentChartHdl,reader);


        tblComponents=prepareTruthTableComponents(sfObj,slciObj,parentChartHdl,reader);
    end
    subComponents=[subCharts;
    states;
    transitions;
    boxComponents;
    gfComponents;
    tblComponents];
end


function subCharts=prepareSubcharts(sfObj,slciObj,reader,mfModel)
    isResultsMF=(nargin==4);

    activeChartObjs=slci.internal.getSFActiveObjs(...
    sfObj.find('-isa','Stateflow.AtomicSubchart','-depth',1));
    chartObjs=setdiff(activeChartObjs,sfObj);
    numSubCharts=numel(chartObjs);
    if numSubCharts>0
        subCharts=cell(numSubCharts,1);
        for i=1:numSubCharts
            chartUDDObj=chartObjs(i).Subchart;
            chartBlk=sfprivate('chart2block',chartUDDObj.Id);
            if isResultsMF
                slciChartObj=createChartObj(chartUDDObj,chartBlk,mfModel);
                slciChartObj.parent(slciObj.key);
                subComponents=prepareComponents(chartUDDObj,slciChartObj,...
                chartBlk,reader,mfModel);
            else
                slciChartObj=createChartObj(chartUDDObj,chartBlk);
                slciChartObj.setParent(slciObj);
                subComponents=prepareComponents(chartUDDObj,slciChartObj,...
                chartBlk,reader);
            end
            if~isempty(subComponents)
                slciChartObj.setComponents(subComponents);
            end
            if isResultsMF
                subCharts{i}=slciChartObj.key;
                reader.insertObject(slciChartObj);
            else
                reader.insertObject(slciChartObj.getKey(),slciChartObj);
                subCharts{i}=slciChartObj.getKey();
            end
        end
    else
        subCharts={};
    end
end


function states=prepareStates(sfObj,slciObj,parentChartHdl,reader,mfModel)
    isResultsMF=(nargin==5);

    activeStateObjs=slci.internal.getSFActiveObjs(...
    sfObj.find('-isa','Stateflow.State','-depth',1));
    stateObjs=setdiff(activeStateObjs,sfObj);
    numStates=numel(stateObjs);
    if numStates>0
        states=cell(numStates,1);
        for i=1:numStates
            stateUDDObj=stateObjs(i);
            stateSID=Simulink.ID.getStateflowSID(stateUDDObj,parentChartHdl);
            stateName=['State ',stateUDDObj.Name,' : '...
            ,num2str(stateUDDObj.SSIdNumber)];
            if isResultsMF
                slciStateObj=slci_results_mf.StateObject(mfModel);
                slciStateObj.initializeStateObject(stateSID,...
                slciObj.key,...
                stateName);
                slciStateObj.isInline=...
                strcmpi(stateUDDObj.InlineOption,'Inline');
                subComponents=prepareComponents(stateUDDObj,slciStateObj,...
                parentChartHdl,reader,mfModel);
            else
                slciStateObj=slci.results.StateObject(stateSID,...
                slciObj,...
                stateName);
                slciStateObj.setIsInline(...
                strcmpi(stateUDDObj.InlineOption,'Inline'))
                subComponents=prepareComponents(stateUDDObj,slciStateObj,...
                parentChartHdl,reader);
            end
            if~isempty(subComponents)
                slciStateObj.setComponents(subComponents);
            end

            if isResultsMF
                states{i}=slciStateObj.key;
                reader.insertObject(slciStateObj);
            else
                reader.insertObject(slciStateObj.getKey(),slciStateObj);
                states{i}=slciStateObj.getKey();
            end
        end
    else
        states={};
    end
end


function transitions=prepareTransitions(sfObj,slciObj,parentChartHdl,reader,mfModel)
    isResultsMF=(nargin==5);

    transitionObjs=slci.internal.getSFActiveObjs(...
    sfObj.find('-isa','Stateflow.Transition','-depth',1));
    numTransitions=numel(transitionObjs);
    if numTransitions>0
        transitions=cell(numTransitions,1);
        for i=1:numTransitions
            transUDDObj=transitionObjs(i);
            transSID=Simulink.ID.getStateflowSID(transUDDObj,parentChartHdl);
            transName=['Transition: ',num2str(transUDDObj.SSIdNumber)];
            if isResultsMF
                slciTransObj=slci_results_mf.StateObject(mfModel);
                slciTransObj.initializeTransitionObject(transSID,...
                slciObj.key,...
                transName);
                transitions{i}=slciTransObj.key;
                reader.insertObject(slciTransObj);
            else
                slciTransObj=slci.results.TransitionObject(transSID,...
                slciObj,...
                transName);
                reader.insertObject(slciTransObj.getKey(),slciTransObj);
                transitions{i}=slciTransObj.getKey();
            end
        end
    else
        transitions={};
    end
end


function boxComponents=prepareBoxComponents(sfObj,slciObj,parentChartHdl,reader,mfModel)

    isResultsMF=(nargin==5);

    activeSfBoxes=slci.internal.getSFActiveObjs(...
    sfObj.find('-isa','Stateflow.Box','-depth',1));
    sfBoxes=setdiff(activeSfBoxes,sfObj);
    boxComponents={};
    for k=1:numel(sfBoxes)
        sfBoxObj=sfBoxes(k);
        if isResultsMF
            boxSubComponents=prepareComponents(sfBoxObj,slciObj,...
            arentChartHdl,reader,mfModel);
        else
            boxSubComponents=prepareComponents(sfBoxObj,slciObj,...
            parentChartHdl,reader);
        end
        boxComponents=[boxComponents;boxSubComponents];%#ok
    end
end


function graphicalfunctions=prepareGraphicalFunctionComponents(sfObj,slciObj,parentChartHdl,...
    reader,mfModel)

    isResultsMF=(nargin==5);

    activeSfGraphicalFunctions=slci.internal.getSFActiveObjs(...
    sfObj.find('-isa','Stateflow.Function','-depth',1));
    sfGraphicalFunctions=setdiff(activeSfGraphicalFunctions,sfObj);

    if~isempty(sfGraphicalFunctions)
        numGFs=numel(sfGraphicalFunctions);
        graphicalfunctions=cell(numGFs,1);
        for i=1:numGFs
            sfGFUddObj=sfGraphicalFunctions(i);
            sfGFSID=Simulink.ID.getStateflowSID(sfGFUddObj,parentChartHdl);
            sfGFName=['GraphicalFunction ',sfGFUddObj.Name,' : '...
            ,num2str(sfGFUddObj.SSIdNumber)];
            if isResultsMF
                slciGFObj=slci_results_mf.GraphicalFunctionObject(mfModel);
                slciGFObj.initializeGraphicalFunctionObject(sfGFSID,...
                slciObj.key,...
                sfGFName);
                slciGFObj.isInline=...
                strcmpi(sfGFUddObj.InlineOption,'Inline');
                subComponents=prepareComponents(sfGFUddObj,slciGFObj,...
                parentChartHdl,reader,mfModel);
                if~isempty(subComponents)
                    slciGFObj.setComponents(subComponents);
                end
                graphicalfunctions{i}=slciGFObj.key;
                reader.insertObject(slciGFObj);
            else
                slciGFObj=slci.results.GraphicalFunctionObject(sfGFSID,...
                slciObj,...
                sfGFName);
                slciGFObj.setIsInline(...
                strcmpi(sfGFUddObj.InlineOption,'Inline'))
                subComponents=prepareComponents(sfGFUddObj,slciGFObj,...
                parentChartHdl,reader);
                if~isempty(subComponents)
                    slciGFObj.setComponents(subComponents);
                end
                reader.insertObject(slciGFObj.getKey(),slciGFObj);
                graphicalfunctions{i}=slciGFObj.getKey();
            end
        end
    else
        graphicalfunctions={};
    end

end


function truthtables=prepareTruthTableComponents(sfObj,slciObj,parentChartHdl,reader,mfModel)

    isResultsMF=(nargin==5);

    activeSfTruthTables=slci.internal.getSFActiveObjs(...
    sfObj.find('-isa','Stateflow.TruthTable','-depth',1));
    sfTruthTables=setdiff(activeSfTruthTables,sfObj);

    if~isempty(sfTruthTables)
        numTTs=numel(sfTruthTables);
        truthtables=cell(numTTs,1);
        for i=1:numTTs
            sfTTUddObj=sfTruthTables(i);
            sfTTSID=Simulink.ID.getStateflowSID(sfTTUddObj,parentChartHdl);
            sfTTName=['GraphicalFunction ',sfTTUddObj.Name,' : '...
            ,num2str(sfTTUddObj.SSIdNumber)];
            if isResultsMF
                slciTTObj=slci_results_mf.GraphicalFunctionObject(mfModel);
                slciTTobj.initializeGraphicalFunctionObject(sfTTSID,...
                slciObj.key,...
                sfTTName);
                slciTTObj.isInline=...
                strcmpi(sfTTUddObj.InlineOption,'Inline');
                subComponents=prepareComponents(sfTTUddObj,slciTTObj,...
                parentChartHdl,reader,mfModel);
                if~isempty(subComponents)
                    slciTTObj.setComponents(subComponents);
                end
                truthtables{i}=slciTTObj.key;
                reader.insertObject(slciTTObj);
            else
                slciTTObj=slci.results.GraphicalFunctionObject(sfTTSID,...
                slciObj,...
                sfTTName);
                slciTTObj.setIsInline(...
                strcmpi(sfTTUddObj.InlineOption,'Inline'))
                subComponents=prepareComponents(sfTTUddObj,slciTTObj,...
                parentChartHdl,reader);
                if~isempty(subComponents)
                    slciTTObj.setComponents(subComponents);
                end
                reader.insertObject(slciTTObj.getKey(),slciTTObj);
                truthtables{i}=slciTTObj.getKey();
            end
        end
    else
        truthtables={};
    end

end

function slciChartObj=createChartObj(chartUDDObj,chartBlk,mfModel)
    isResultsMF=(nargin==3);



    chartSID=Simulink.ID.getStateflowSID(chartUDDObj,chartBlk);
    chartName=get_param(chartSID,'Name');
    if isResultsMF
        slciChartObj=slci_results_mf.ChartObject(mfModel);
        slciChartObj.initializeChartObject(chartSID,chartName);
        chartSubObjects=chartUDDObj.find;
        if isempty(setdiff(chartSubObjects,chartUDDObj))
            slciChartObj.setIsEmpty();
        end
        if strcmpi(get_param(chartBlk,'RTWSystemCode'),'Inline')
            slciChartObj.setIsInline();
        end
    else
        slciChartObj=slci.results.ChartObject(chartSID,chartName);
        chartSubObjects=chartUDDObj.find;
        if isempty(setdiff(chartSubObjects,chartUDDObj))
            slciChartObj.setIsEmpty(true);
        end
        if strcmpi(get_param(chartBlk,'RTWSystemCode'),'Inline')
            slciChartObj.setIsInline(true);
        else
            slciChartObj.setIsInline(false);
        end
    end
end
