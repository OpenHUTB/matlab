





function[ResultDescription,ResultHandles]=ExecCheckOptimizationSettings(system)

    ResultDescription={};
    ResultHandles={};

    model=bdroot(system);

    cs=getActiveConfigSet(model);
    mdladvObj=Simulink.ModelAdvisor.getModelAdvisor(system);
    mdladvObj.setCheckResultStatus(false);





    csParamTable=cell(0,3);


    if strcmp(safe_get_param(cs,'BlockReduction'),'off')
        csParamTable(end+1,:)={'BlockReduction','off','on'};
    end

    if strcmp(safe_get_param(cs,'ConditionallyExecuteInputs'),'off')
        csParamTable(end+1,:)={'ConditionallyExecuteInputs','off','on'};
    end

    if strcmp(safe_get_param(cs,'BooleanDataType'),'off')
        csParamTable(end+1,:)={'BooleanDataType','off','on'};
    end

    if strcmp(safe_get_param(cs,'OptimizeBlockIOStorage'),'off')
        csParamTable(end+1,:)={'OptimizeBlockIOStorage','off','on'};
    end


    verInfo=ver;
    productNames={verInfo.Name};
    hasSimulinkCoder=any(strcmp(productNames,'Simulink Coder'));


    isERT=strcmp(get_param(cs,'IsERTTarget'),'on')&&...
    license('test','Real-Time_Workshop')&&hasSimulinkCoder;


    if license('test','Real-Time_Workshop')&&hasSimulinkCoder
        if strcmp(safe_get_param(cs,'LocalBlockOutputs'),'off')
            csParamTable(end+1,:)={'LocalBlockOutputs','off','on'};
        end

        if strcmp(safe_get_param(cs,'BufferReuse'),'off')
            csParamTable(end+1,:)={'BufferReuse','off','on'};
        end

        if strcmp(safe_get_param(cs,'ExpressionFolding'),'off')
            csParamTable(end+1,:)={'ExpressionFolding','off','on'};
        end

        if strcmp(safe_get_param(cs,'InitFltsAndDblsToZero'),'on')
            csParamTable(end+1,:)={'InitFltsAndDblsToZero','on','off'};
        end
        if strcmp(safe_get_param(cs,'EfficientFloat2IntCast'),'off')
            csParamTable(end+1,:)={'EfficientFloat2IntCast','off','on'};
        end
        if strcmp(safe_get_param(cs,'InlineInvariantSignals'),'off')
            csParamTable(end+1,:)={'InlineInvariantSignals','off','on'};
        end
    end


    if~strcmp(safe_get_param(cs,'ConsistencyChecking'),'none')
        csParamTable(end+1,:)={'ConsistencyChecking',...
        safe_get_param(cs,'ConsistencyChecking'),'none'};
    end


    if~strcmp(safe_get_param(cs,'ArrayBoundsChecking'),'none')
        csParamTable(end+1,:)={'ArrayBoundsChecking',...
        safe_get_param(cs,'ArrayBoundsChecking'),'none'};
    end


    if~strcmp(safe_get_param(cs,'SignalRangeChecking'),'none')
        csParamTable(end+1,:)={'SignalRangeChecking',...
        safe_get_param(cs,'SignalRangeChecking'),'none'};
    end


    rt=sfroot;
    sfMachine=rt.find('-isa','Stateflow.Machine','-and','Name',getfullname(model));
    sfChart=sfMachine.find('-isa','Stateflow.Chart');

    if~isempty(sfChart)
        if strcmp(safe_get_param(cs,'StateBitsets'),'off')
            csParamTable(end+1,:)={'StateBitsets','off','on'};
        end

        if strcmp(safe_get_param(cs,'DataBitsets'),'off')
            csParamTable(end+1,:)={'DataBitsets','off','on'};
        end
    end

    if isERT
        if strcmp(safe_get_param(cs,'LifeSpan'),'inf')&&...
            strcmp(safe_get_param(cs,'SupportAbsoluteTime'),'on')
            csParamTable(end+1,:)={'SupportAbsoluteTime','on','off'};
        end

        if strcmp(safe_get_param(cs,'CombineOutputUpdateFcns'),'off')
            csParamTable(end+1,:)={'CombineOutputUpdateFcns','off','on'};
        end



        if strcmp(safe_get_param(cs,'ZeroExternalMemoryAtStartup'),'on')
            csParamTable(end+1,:)={'ZeroExternalMemoryAtStartup','on','off'};
        end

        if strcmp(safe_get_param(cs,'ZeroInternalMemoryAtStartup'),'on')
            csParamTable(end+1,:)={'ZeroInternalMemoryAtStartup','on','off'};
        end

        if strcmp(safe_get_param(cs,'PassReuseOutputArgsAs'),'Structure reference')
            csParamTable(end+1,:)={'PassReuseOutputArgsAs',...
            'Structure reference','Individual arguments'};
        end


        if strcmp(safe_get_param(cs,'IgnoreTestpoints'),'off')
            csParamTable(end+1,:)={'IgnoreTestpoints',...
            'off','on'};
        end
    end



    if~isempty(csParamTable)
        ft=ModelAdvisor.FormatTemplate('TableTemplate');

        colHeadings={...
        DAStudio.message('Advisor:engine:Parameter'),...
        DAStudio.message('Advisor:engine:CurrentValue'),...
        DAStudio.message('Advisor:engine:RecValues')};

        hasInvertedLogicParameter=false;

        for n=1:size(csParamTable,1)
            paramName=csParamTable{n,1};

            if isParameterWithInvertedLogic(model,paramName)

                link=Advisor.Utils.getHyperlinkToConfigSetParameter(model,paramName);
                link.Content=[link.Content,'*'];
                csParamTable{n,1}=link;
                hasInvertedLogicParameter=true;
            else
                csParamTable{n,1}=Advisor.Utils.getHyperlinkToConfigSetParameter(model,paramName);
            end
        end

        ft.setColTitles(colHeadings);
        ft.setTableInfo(csParamTable);
        ft.setSubResultStatus('Warn');

        if hasInvertedLogicParameter
            ft.setRecAction([...
            ModelAdvisor.Text(DAStudio.message('Advisor:engine:CCOFModelParamRecAct')),...
            ModelAdvisor.Text(DAStudio.message('Advisor:engine:CCOFModelParamInvertedLogicFootnote'))]);
        else
            ft.setRecAction(ModelAdvisor.Text(DAStudio.message('Advisor:engine:CCOFModelParamRecAct')));
        end

        ResultDescription{end+1}=ft;
        ResultHandles{end+1}=[];
    end



    try


        mdlList=find_mdlrefs(model,'MatchFilter',@Simulink.match.internal.filterOutCodeInactiveVariantSubsystemChoices);

        mdlList=mdladvObj.filterResultWithExclusion(mdlList);
        numMdls=length(mdlList);
    catch %#ok<CTCH>


        numMdls=0;
    end

    if numMdls>1
        isOffendingModel=false(size(mdlList));


        for idx=1:numMdls-1
            thisMdl=mdlList{idx};


            mdlsToClose=slprivate('load_model',thisMdl);
            byRef=get_param(thisMdl,'ModelReferencePassRootInputsByReference');

            if strcmpi(byRef,'on')
                isOffendingModel(idx)=true;
            end

            slprivate('close_models',mdlsToClose);
        end

        offsenseMdls=mdlList(isOffendingModel);


        if~isempty(offsenseMdls)
            paramPrompt=ModelAdvisor.Text(...
            Advisor.Utils.getConfigSetParameterUIPrompt(model,'ModelReferencePassRootInputsByReference'));
            paramPrompt.setBold(true);

            ft2=ModelAdvisor.FormatTemplate('ListTemplate');
            ft2.setSubResultStatus('Warn');
            ft2.setSubResultStatusText(DAStudio.message('ModelAdvisor:engine:MdlRefRootOutportByRef'));




            offsenseMdlsLinks=cell(size(offsenseMdls));
            for n=1:length(offsenseMdls)
                link=ModelAdvisor.Text(offsenseMdls{n});
                link.setHyperlink(['matlab: ',offsenseMdls{n}]);
                offsenseMdlsLinks{n}=link;
            end
            ft2.setListObj(offsenseMdlsLinks);
            ft2.setRecAction(DAStudio.message('ModelAdvisor:engine:MdlRefRootOutportByRefRecAct',paramPrompt.emitHTML()));
            ResultDescription{end+1}=ft2;
            ResultHandles{end+1}=[];
        end
    end


    if isempty(ResultDescription)

        ft=ModelAdvisor.FormatTemplate('ListTemplate');
        ft.setSubResultStatus('Pass');
        ft.setCheckText(...
        DAStudio.message('ModelAdvisor:engine:OptimizationSettingsDescription'));
        ft.setSubBar(0);
        ResultDescription{end+1}=ft;
        ResultHandles{end+1}=[];
        mdladvObj.setCheckResultStatus(true);
    else
        ResultDescription{end}.setSubBar(0);

        ResultDescription{1}.setCheckText(...
        DAStudio.message('ModelAdvisor:engine:OptimizationSettingsDescription'));
    end
end

function value=safe_get_param(cs,paramName)
    if cs.isValidParam(paramName)
        value=get_param(cs,paramName);
    else
        value='not valid field';
    end
end

function status=isParameterWithInvertedLogic(system,paramName)
    status=false;
    try
        systemObj=get_param(bdroot(system),'object');
        cs=systemObj.getActiveConfigSet();
        adp=configset.internal.getConfigSetAdapter(cs);
        p=adp.getParamData(paramName);
        status=p.isInvertValue;
    catch
    end
end
