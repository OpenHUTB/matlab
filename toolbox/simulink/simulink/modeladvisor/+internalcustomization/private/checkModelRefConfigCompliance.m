function ResultDescription=checkModelRefConfigCompliance(system,mode)



    ResultDescription={};
    ResultStatus=true;
    topModel=bdroot(system);
    mdlAdvObj=Simulink.ModelAdvisor.getModelAdvisor(system);
    mdlAdvObj.setCheckResultStatus(ResultStatus);
    topModelName=get_param(topModel,'Name');

    try


        childModels=loc_getAllModelsToBeReported(system,mode);


        headID=['Simulink:tools:MAModelRef',mode,'ConfigCheckInfo'];
        header=ModelAdvisor.Text(DAStudio.message(headID,topModelName));


        modelResults=[];
        for i=1:length(childModels)
            locResult=loc_getCheckResultsForModel(childModels{i},mode);
            if~isempty(locResult)
                if isempty(modelResults)
                    modelResults=ModelAdvisor.List();
                    modelResults.setType('bulleted');
                end
                modelResults.addItem(locResult);
            end
        end

        if isempty(modelResults)
            result=ModelAdvisor.Text(DAStudio.message('Simulink:tools:MAModelRefConfigCheckPassText'));
        else

            msgID=['Simulink:tools:MAModelRefConfigCheckRecAction',mode];
            text=ModelAdvisor.Text(DAStudio.message(msgID));
            paragraph=ModelAdvisor.Paragraph(text);
            result=[header,modelResults,paragraph];
        end

        ResultDescription{end+1}=result;
    catch E
        result=E.message;
        ResultStatus=false;
        ResultDescription{end+1}=['<p/><font color="#800000">'...
        ,DAStudio.message('Simulink:tools:MAAnalysisThrewError',result),'</font>'];
    end

    mdlAdvObj.setCheckResultStatus(ResultStatus);
end

function models=loc_getAllModelsToBeReported(topModel,mode)
    models={};








    if isequal(mode,'SIM')
        [~,~,aGraph]=find_mdlrefs(topModel,'MatchFilter',@Simulink.match.internal.filterOutInactiveVariantSubsystemChoices,...
        'IncludeProtectedModels',false,'IncludeCommented','off');
        analyzer=Simulink.ModelReference.internal.GraphAnalysis.ModelRefGraphAnalyzer;
        result=analyzer.analyze(aGraph,'AnyAccel','IncludeTopModel',true);
        if~isempty(result)
            models=result.RefModel;
        end
    else
        models=find_mdlrefs(topModel,...
        'MatchFilter',@Simulink.match.internal.filterOutCodeInactiveVariantSubsystemChoices,...
        'IncludeProtectedModels',false,'IncludeCommented','off');
    end

    models=models(~strcmp(topModel,models));
end

function result=loc_getCheckResultsForModel(model,mode)
    result={};
    dsmBlocksResult={};
    paramsTableResult={};

    modelsToClose=slprivate('load_model',model);
    modelName=get_param(model,'Name');

    csActive=getActiveConfigSet(model);

    isConfigSetRef=isa(csActive,'Simulink.ConfigSetRef');

    if isConfigSetRef
        cs=csActive.getRefConfigSet;
    else
        cs=csActive;
    end

    paramsList=cs.modelAdvisorCheckMdlRefCompliance(mode,modelName);


    if isequal(mode,'SIM')
        dsmBlocksResult=locCheckLocalDSMDiagnostics(modelName,cs);
    end


    if~isempty(paramsList)

        paramsTableResult=locCreateTableForModelRefConfigCompliance(modelName,paramsList,cs);
    end

    if~isempty(dsmBlocksResult)||~isempty(paramsTableResult)

        header0=ModelAdvisor.Text(DAStudio.message('Simulink:tools:MAModelRefConfigCheckModelHeader'));
        header0.setBold('true');
        header=ModelAdvisor.Text(modelName);
        header.setBold('true');
        header.setHyperlink(['matlab:open_system(''',modelName,''');']);
        result=ModelAdvisor.Paragraph([header0,header,paramsTableResult,dsmBlocksResult]);
    end

    slprivate('close_models',modelsToClose);
end

function result=locCheckLocalDSMDiagnostics(modelName,cs)
    result={};
    header={};
    list={};
    if Simulink.internal.useFindSystemVariantsMatchFilter()
        blocks=find_system(modelName,...
        'FollowLinks','on',...
        'LookUnderMasks','all',...
        'MatchFilter',@Simulink.match.activeVariants,...
        'IncludeCommented','off',...
        'BlockType','DataStoreMemory');
    else
        blocks=find_system(modelName,...
        'FollowLinks','on',...
        'LookUnderMasks','all',...
        'Variants','ActiveVariants',...
        'IncludeCommented','off',...
        'BlockType','DataStoreMemory');
    end

    for i=1:length(blocks)
        if locEvaluateDSMDiagnosticForBlock(cs,blocks{i})

            if isempty(header)
                header=ModelAdvisor.Text(DAStudio.message('Simulink:tools:MAModelRefConfigCheckDSMHeader'));
                list=ModelAdvisor.List();
                list.setType('bulleted');
            end

            item=ModelAdvisor.Text(blocks{i});

            blockName=regexprep(blocks{i},'\n',' ');
            item.setHyperlink(strcat('matlab:open_system(''',modelName,''');hilite_system(''',blockName,''');'));
            list.addItem(item);
        end
    end

    if~isempty(header)&&~isempty(list)
        result=ModelAdvisor.Paragraph([header,list]);
    end
end

function result=locEvaluateDSMDiagnosticForBlock(cs,block)
    result=false;
    params={'ReadBeforeWriteMsg','WriteAfterReadMsg','WriteAfterWriteMsg'};
    index=1;

    while(~result&&index<=length(params))
        param=params{index};

        csParam=get_param(cs,param);
        blockParam=get_param(block,param);



        result=(~isempty(regexpi(csParam,'EnableAll'))||...
        (isequal(csParam,'UseLocalSettings')&&...
        ~isequal(blockParam,'none')));

        index=index+1;
    end
end

function result=locCreateTableForModelRefConfigCompliance(modelName,paramsList,cs)

    table=ModelAdvisor.Table(length(paramsList),2);
    table.setColHeading(1,DAStudio.message('Simulink:tools:MAModelRefConfigCheckTableCol1'));
    table.setColHeading(2,DAStudio.message('Simulink:tools:MAModelRefConfigCheckTableCol2'));


    for i=1:length(paramsList)

        param=configset.getParameterInfo(cs,paramsList{i});


        if isempty(param.Description)
            linktext=paramsList{i};
        else

            uiNamePrompt=regexprep(param.Description,':','');
            linktext=[uiNamePrompt,' (',paramsList{i},')'];
        end
        link=ModelAdvisor.Text(linktext);
        link.setHyperlink(['matlab:load_system(''',modelName,''');modeladvisorprivate openCSAndHighlight ',modelName,' ',paramsList{i}]);


        table.setEntry(i,1,link);
        table.setEntry(i,2,param.DisplayValue);
        table.setEntryAlign(i,2,'center');
    end
    result=table;
end
