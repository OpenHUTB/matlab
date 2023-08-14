function printBuildSummary(entries,numModelsBuilt,numModelsUpToDate,...
    numModels,okToPushNags,topMdl,buildDuration,...
    isSimulinkAccelerator,isRapidAccelerator)





    buffer='';



    title=string(message('Simulink:slbuild:bsBuildSummaryTitle'));
    if okToPushNags
        diagStage=Simulink.output.Stage(...
        title,...
        'ModelName',topMdl,'UIMode',true);
    else
        buffer=[buffer,sprintf('\n%s\n\n',title)];
    end


    [simTargets,coderTargets,topModelTarget]=locGroupByTarget(entries);

    if~isempty(simTargets)
        title=string(message('Simulink:slbuild:bsSimTargetsBuilt'));
        table=locFormatSummaryTable(simTargets,title);
        buffer=[buffer,table];
    end

    if~isempty(coderTargets)
        title=string(message('Simulink:slbuild:bsCoderTargetsBuilt'));
        table=locFormatSummaryTable(coderTargets,title);
        buffer=[buffer,table];
    end

    if~isempty(topModelTarget)
        if isSimulinkAccelerator
            title=string(message('Simulink:slbuild:bsTopModelAcceleratorTargetsBuilt'));
        elseif isRapidAccelerator
            title=string(message('Simulink:slbuild:bsTopModelRapidAcceleratorTargetsBuilt'));
        else
            title=string(message('Simulink:slbuild:bsTopModelTargetsBuilt'));
        end
        table=locFormatSummaryTable(topModelTarget,title);
        buffer=[buffer,table];
    end

    summaryStats=locFormatSummaryStats(numModels,numModelsBuilt,numModelsUpToDate,buildDuration);
    buffer=[buffer,summaryStats];
    if~isempty(buffer)
        Simulink.output.info(buffer);
    end

    if okToPushNags
        delete(diagStage);
    end
end

function[simTargets,coderTargets,topModelTarget]=locGroupByTarget(entries)
    simTargets=[];
    coderTargets=[];
    topModelTarget=[];
    if~isempty(entries)
        targets={entries.Target};


        simTargetsIdx=strcmp(targets,'SIM');
        simTargets=entries(simTargetsIdx);


        coderTargetsIdx=strcmp(targets,'RTW');
        coderTargets=entries(coderTargetsIdx);


        topModelTargetIdx=strcmp(targets,'NONE');
        topModelTarget=entries(topModelTargetIdx);
    end
end

function summaryTable=locFormatSummaryTable(entries,header)

    sectionTitle=sprintf('%s\n\n',header);

    modelNames={entries.Model};
    actions=locGetActionMessages(entries);
    reasons={entries.RebuildReason};

    padding=2;
    modelHeader=string(message('Simulink:slbuild:bsModelHeader'));
    actionsHeader=string(message('Simulink:slbuild:bsActionHeader'));
    reasonsHeader=string(message('Simulink:slbuild:bsReasonsHeader'));

    modelNamesColWidth=max(strlength([modelHeader,modelNames]))+padding;
    actionsColWidth=max(strlength([actionsHeader,actions]))+padding;
    reasonsColWidth=max(strlength([reasonsHeader,reasons]))+padding;

    fmt=['%-',num2str(modelNamesColWidth),'s%-',num2str(actionsColWidth),'s%-',num2str(reasonsColWidth),'s\n'];

    tableColHeaders={modelHeader;actionsHeader;reasonsHeader};
    tableHeader=sprintf(fmt,tableColHeaders{:});

    tableWidth=modelNamesColWidth+actionsColWidth+reasonsColWidth;
    headerDivider=sprintf('%s\n',repmat('=',1,tableWidth));

    allData=[modelNames;actions;reasons];
    tableData=sprintf(fmt,allData{:});

    summaryTable=[sectionTitle,tableHeader,headerDivider,tableData,newline];
end

function summaryStats=locFormatSummaryStats(numModels,numModelsBuilt,numModelsUpToDate,buildDuration)

    upToDateMsg=string(message('Simulink:slbuild:bsModelsBuilt',numModelsBuilt,numModels,numModelsUpToDate));
    durationMsg=string(message('Simulink:slbuild:bsBuildDuration',char(buildDuration)));
    summaryStats=sprintf('%s\n%s',upToDateMsg,durationMsg);
end

function actions=locGetActionMessages(entries)
    actions=arrayfun(@(e)getActionMessage(e),entries,'UniformOutput',false);
end

function result=getActionMessage(entry)
    if entry.ActionUnknown


        result=string(message('Simulink:slbuild:bsActionRebuilt'));
    elseif entry.WasCodeGenerated&&entry.WasCodeCompiled
        result=string(message('Simulink:slbuild:bsCodeGenAndCompile'));
    elseif entry.WasCodeGenerated
        result=string(message('Simulink:slbuild:bsCodeGen'));
    elseif entry.WasCodeCompiled
        result=string(message('Simulink:slbuild:bsCodeCompile'));
    elseif~entry.WasBuildSuccessful
        result=string(message('Simulink:slbuild:bsActionFailed'));
    else


        result='';
    end
end


