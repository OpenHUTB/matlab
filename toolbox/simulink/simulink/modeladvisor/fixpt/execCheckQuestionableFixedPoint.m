


function[ResultDescription,ResultHandles]=execCheckQuestionableFixedPoint(system)
    ResultHandles={};

    mdladvObj=Simulink.ModelAdvisor.getModelAdvisor(system);

    mdladvObj.setCheckResultStatus(false);
    ResultDescription={};

    ResultDescription=addResults(@()getResultsMultiwordOps(system),ResultDescription);
    ResultDescription=addResults(@()getResultsCumbersomeMultiply(system),ResultDescription);


    if modeladvisorprivate('modeladvisorutil2','FeatureControl','fixedPointUtilityScope')
        ft=generateCumberSomeMultiplyNote(system);
        if~isempty(ft)
            ResultDescription{1}.subBar=false;
            ResultDescription{end+1}=ft;
        end
    end
    ResultDescription=addResults(@()getResultsCumbersomeDivide(system),ResultDescription);
    ResultDescription=addResults(@()getResultsLookupSpacing(system),ResultDescription);
    ResultDescription=addResults(@()getResultsPrelookupDivision(system),ResultDescription);
    ResultDescription=addResults(@()getResultsDatatypeConversion(system),ResultDescription);
    ResultDescription=addResults(@()getResultsFixptUnaryRelop(system),ResultDescription);
    ResultDescription=addResults(@()getResultsFixptBinaryRelop(system),ResultDescription);
    if(slfeature('EmulatedTypeCheck')>0)
        ResultDescription=addResults(@()getResultsFixptEmulatedTypes(system),ResultDescription);
    end

    mdladvObj.setCheckResultStatus(getResultsStatus(ResultDescription));



    function ft=generateCumberSomeMultiplyNote(system)
        ft=[];
        lookup=local_findSystem(system,'BlockType','Lookup_n-D');
        sinecosine=local_findSystem(system,'MaskType','Sine and Cosine');
        sqrt=local_findSystem(system,'BlockType','Sqrt');
        cumbersomeMulInUtilScopePossible=~isempty(lookup)||...
        ~isempty(sinecosine)||...
        ~isempty(sqrt);

        if cumbersomeMulInUtilScopePossible
            utilityScopeBlockTypesStr='';
            if~isempty(lookup)
                utilityScopeBlockTypesStr=[utilityScopeBlockTypesStr,'Lookup_n-D'];
            end
            if~isempty(sinecosine)
                utilityScopeBlockTypesStr=[utilityScopeBlockTypesStr,'Sine or Cosine'];
            end
            if~isempty(sqrt)
                utilityScopeBlockTypesStr=[utilityScopeBlockTypesStr,'Sqrt'];
            end
            ft=ModelAdvisor.FormatTemplate('ListTemplate');
            utilityScopeNote=ModelAdvisor.Text(DAStudio.message('ModelAdvisor:engine:UtilityScopePossibleMuls',utilityScopeBlockTypesStr));
            utilityScopeNote.setBold(true);
            ft.setCheckText(utilityScopeNote);
            ft.subBar=true;

        end



        function results=addResults(fcn,res)
            results=res;
            currentResults=fcn();
            if isempty(currentResults)
                return;
            end
            if iscell(currentResults)
                for i=1:numel(currentResults)
                    results{end+1}=currentResults{i};%#ok<AGROW>
                end
            else
                results{end+1}=currentResults;
            end



            function results=getResultsMultiwordOps(system)
                parsedOutput=Advisor.RegisterCGIRInspectorResults.getInstance.parseCGIRResults('NODE_MULTIWORD_OPS',true,system);
                if~isempty(parsedOutput)&&numel(parsedOutput.tag)>=2
                    parsedOutput=collapseBlkResults(parsedOutput);
                end


                ft=ModelAdvisor.FormatTemplate('TableTemplate');
                ft.setSubTitle(DAStudio.message('ModelAdvisor:engine:FxpCheckMultiwordOps_Title'));
                if~isempty(parsedOutput)
                    ft.setSubResultStatus('warn');
                    ft.setInformation(DAStudio.message('ModelAdvisor:engine:FxpCheckMultiwordOps'));
                    ft.setSubBar(true);
                    ft.setColTitles({DAStudio.message('ModelAdvisor:engine:FxpBlockIDCol'),...
                    DAStudio.message('ModelAdvisor:engine:FxpMultiwordFcnCol')});
                    for idx=1:numel(parsedOutput.tag)
                        fcnName=parsedOutput.tag{idx}.info('FunctionName');
                        ft.addRow({parsedOutput.tag{idx}.sid,fcnName});
                    end
                else
                    ft.setSubResultStatus('pass');
                end
                results=ft;



                function parsedOutput=collapseBlkResults(parsedOutput)
                    for idx=numel(parsedOutput.tag):-1:2
                        blkSID=parsedOutput.tag{idx}.sid;
                        prevBlkSID=parsedOutput.tag{idx-1}.sid;
                        if isequal(blkSID,prevBlkSID)
                            parsedOutput.tag{idx}.sid='';
                        end
                    end


                    function results=getResultsCumbersomeMultiply(system)
                        parsedOutput=Advisor.RegisterCGIRInspectorResults.getInstance.parseCGIRResults('NODE_CUMBERSOME_MULTIPLY',true,system);


                        ft=ModelAdvisor.FormatTemplate('TableTemplate');
                        ft.setSubTitle(DAStudio.message('ModelAdvisor:engine:FxpCheckCumbersomeMultiply_Title'));
                        if~isempty(parsedOutput)
                            ft.setSubResultStatus('warn');
                            ft.setInformation(DAStudio.message('ModelAdvisor:engine:FxpCheckCumbersomeMultiply'));
                            ft.setSubBar(false);
                            ft.setColTitles({DAStudio.message('ModelAdvisor:engine:FxpBlockIDCol'),...
                            DAStudio.message('ModelAdvisor:engine:FxpCumbersomeFcnCol')});
                            for idx=1:numel(parsedOutput.tag)
                                ft.addRow({parsedOutput.tag{idx}.sid,...
                                parsedOutput.tag{idx}.info('FunctionName')});
                            end
                        else
                            ft.setSubResultStatus('pass');
                        end
                        results=ft;


                        function results=getResultsCumbersomeDivide(system)
                            parsedOutput=Advisor.RegisterCGIRInspectorResults.getInstance.parseCGIRResults('NODE_CUMBERSOME_DIVIDE',true,system);


                            ft=ModelAdvisor.FormatTemplate('TableTemplate');
                            ft.setSubTitle(DAStudio.message('ModelAdvisor:engine:FxpCheckCumbersomeDivide_Title'));
                            if~isempty(parsedOutput)
                                ft.setSubResultStatus('warn');
                                ft.setInformation(DAStudio.message('ModelAdvisor:engine:FxpCheckCumbersomeDivide'));
                                ft.setSubBar(false);
                                ft.setColTitles({DAStudio.message('ModelAdvisor:engine:FxpBlockIDCol'),...
                                DAStudio.message('ModelAdvisor:engine:FxpCumbersomeFcnCol')});
                                for idx=1:numel(parsedOutput.tag)
                                    ft.addRow({parsedOutput.tag{idx}.sid,...
                                    parsedOutput.tag{idx}.info('FunctionName')});
                                end
                            else
                                ft.setSubResultStatus('pass');
                            end
                            results=ft;


                            function results=getResultsLookupSpacing(system)
                                results={};
                                parsedOutput=Advisor.RegisterCGIRInspectorResults.getInstance.parseCGIRResults('NODE_LOOKUP_SPACING',true,system);

                                subCheckMessageMap=containers.Map('KeyType','char','ValueType','any');
                                checkIDToMsgIDMap={...
                                'EVEN_SPACING_NOT_POWER2_EVEN_SEARCH','FxpCheckLookupSpacing_EvenSpacingNotPow2WithEvenSearch';...
                                'EVEN_SPACING_POWER2_NOT_EVEN_SEARCH','FxpCheckLookupSpacing_EvenSpacingPow2WithNonEvenSearch';...
                                'EVEN_SPACING_NOT_POWER2_NOT_EVEN_SEARCH','FxpCheckLookupSpacing_EvenSpacingNotPow2WithNonEvenSearch';...
                                'NOT_EVEN_SPACING_NOT_EVEN_SEARCH','FxpCheckLookupSpacing_NotEvenSpacingWithNonEvenSearch';...
                                };


                                isTunableParameterBehavior=strcmp(get_param(bdroot(system),'DefaultParameterBehavior'),'Tunable');
                                for ii=1:size(checkIDToMsgIDMap,1)

                                    if isTunableParameterBehavior
                                        msgString=DAStudio.message('ModelAdvisor:engine:FxpCheckLookupSpacing_DefaultParameterBehavior');
                                    else
                                        msgString=DAStudio.message(['ModelAdvisor:engine:',checkIDToMsgIDMap{ii,2}]);
                                    end
                                    subCheckMessageMap(checkIDToMsgIDMap{ii,1})=msgString;
                                end

                                if~isempty(parsedOutput)
                                    subCheckResultsMap=containers.Map('KeyType','char','ValueType','any');
                                    for idx=1:numel(parsedOutput.tag)
                                        subCheck=parsedOutput.tag{idx}.info('SubCheck');
                                        if~isKey(subCheckResultsMap,subCheck)
                                            subCheckResultsMap(subCheck)={};
                                        end
                                        x=subCheckResultsMap(subCheck);
                                        x{end+1}=parsedOutput.tag{idx};%#ok<AGROW>
                                        subCheckResultsMap(subCheck)=x;
                                    end

                                    keys=subCheckResultsMap.keys();
                                    if isTunableParameterBehavior
                                        nEntries=1;
                                    else
                                        nEntries=numel(keys);
                                    end
                                    passStatus='warn';
                                    for idx=1:nEntries

                                        ft=ModelAdvisor.FormatTemplate('TableTemplate');
                                        if numel(results)==0
                                            ft.setSubTitle(DAStudio.message('ModelAdvisor:engine:FxpCheckLookupSpacing_Title'));
                                        end
                                        ft.setSubResultStatusText(subCheckMessageMap(keys{idx}));
                                        ft.setSubResultStatus(passStatus);
                                        ft.setSubBar(false);
                                        ft.setColTitles({DAStudio.message('ModelAdvisor:engine:FxpBlockIDCol')});




                                        if~isTunableParameterBehavior
                                            for i=1:numel(subCheckResultsMap(keys{idx}))
                                                item=subCheckResultsMap(keys{idx});
                                                ft.addRow({item{i}.sid});
                                            end
                                        end
                                        results{end+1}=ft;%#ok<AGROW>
                                    end
                                else
                                    ft=ModelAdvisor.FormatTemplate('TableTemplate');
                                    ft.setSubTitle(DAStudio.message('ModelAdvisor:engine:FxpCheckLookupSpacing_Title'));
                                    ft.setSubResultStatus('pass');
                                    results{end+1}=ft;
                                end
                                results{end}.setSubBar(true);


                                function results=getResultsPrelookupDivision(system)
                                    parsedOutput=Advisor.RegisterCGIRInspectorResults.getInstance.parseCGIRResults('NODE_PRELOOKUP_DIVISION',true,system);

                                    ft=ModelAdvisor.FormatTemplate('TableTemplate');
                                    ft.setSubTitle(DAStudio.message('ModelAdvisor:engine:FxpCheckPrelookupDivision_Title'));
                                    if~isempty(parsedOutput)
                                        ft.setSubResultStatus('warn');
                                        ft.setSubResultStatusText(DAStudio.message('ModelAdvisor:engine:FxpCheckPreLookupDivision'));
                                        ft.setSubBar(false);
                                        ft.setColTitles({DAStudio.message('ModelAdvisor:engine:FxpBlockIDCol'),...
                                        DAStudio.message('ModelAdvisor:engine:FxpSearchMethCol')});
                                        for idx=1:numel(parsedOutput.tag)
                                            ft.addRow({parsedOutput.tag{idx}.sid,...
                                            parsedOutput.tag{idx}.info('SearchMethod')});
                                        end
                                    else
                                        ft.setSubResultStatus('pass');
                                    end

                                    results=ft;



                                    function results=getResultsFixptBinaryRelop(system)
                                        results={};
                                        subCheckMessageMap=containers.Map('KeyType','char','ValueType','any');
                                        subCheckMessageMap('U1_MAX')=DAStudio.message('ModelAdvisor:engine:FxpCheckBinaryRelop_U1Max');
                                        subCheckMessageMap('U1_SLOPE')=DAStudio.message('ModelAdvisor:engine:FxpCheckBinaryRelop_U1Slope');
                                        subCheckMessageMap('U2_MAX')=DAStudio.message('ModelAdvisor:engine:FxpCheckBinaryRelop_U2Max');
                                        subCheckMessageMap('U2_SLOPE')=DAStudio.message('ModelAdvisor:engine:FxpCheckBinaryRelop_U2Slope');
                                        subCheckMessageMap('NET_SLOPE_QUANTIZATION')=DAStudio.message('ModelAdvisor:engine:FxpCheckBinaryRelop_MismatchSlope');

                                        checkGroups=containers.Map('KeyType','char','ValueType','any');

                                        parsedOutput=Advisor.RegisterCGIRInspectorResults.getInstance.parseCGIRResults('NODE_FIXPT_BINARY_RELOP',true,system);

                                        if~isempty(parsedOutput)
                                            for idx=1:numel(parsedOutput.tag)
                                                subCheck=parsedOutput.tag{idx}.info('SubCheck');
                                                if~isKey(checkGroups,subCheck)
                                                    checkGroups(subCheck)={};
                                                end
                                                group=checkGroups(subCheck);
                                                group{end+1}=parsedOutput.tag{idx};%#ok<AGROW>
                                                checkGroups(subCheck)=group;
                                            end

                                            for idx=1:numel(keys(checkGroups))
                                                groupKeys=keys(checkGroups);
                                                key=groupKeys{idx};

                                                results{end+1}=ModelAdvisor.FormatTemplate('TableTemplate');%#ok<AGROW>
                                                if numel(results)==1
                                                    results{end}.setSubTitle(DAStudio.message('ModelAdvisor:engine:FxpCheckBinaryRelop_Title'));
                                                end
                                                results{end}.setSubResultStatus('warn');
                                                results{end}.setSubResultStatusText(subCheckMessageMap(key));
                                                results{end}.setSubBar(false);
                                                results{end}.setColTitles({DAStudio.message('ModelAdvisor:engine:FxpBlockIDCol'),...
                                                DAStudio.message('ModelAdvisor:engine:FxpSubCheckCol')});
                                                for i=1:numel(checkGroups(groupKeys{idx}))
                                                    group=checkGroups(groupKeys{idx});
                                                    match=group{i};
                                                    results{end}.addRow({match.sid,match.info('SubCheck')});
                                                end
                                            end
                                        else
                                            results{end+1}=ModelAdvisor.FormatTemplate('TableTemplate');
                                            results{end}.setSubTitle(DAStudio.message('ModelAdvisor:engine:FxpCheckBinaryRelop_Title'));
                                            results{end}.setSubResultStatus('pass');
                                        end



                                        function results=getResultsDatatypeConversion(system)
                                            results={};
                                            parsedOutput=Advisor.RegisterCGIRInspectorResults.getInstance.parseCGIRResults('NODE_DATATYPE_CONVERSION',true,system);

                                            subCheckMessageMap=containers.Map('KeyType','char','ValueType','any');
                                            subCheckMessageMap('NET_SLOPE_CHANGE_RND_METHOD')=...
                                            DAStudio.message('ModelAdvisor:engine:FxpCheckDatatypeConversion_NetSlopeChangeRndMethod');
                                            subCheckMessageMap('NET_SLOPE_CHANGE_HW_RND_METHOD')=...
                                            DAStudio.message('ModelAdvisor:engine:FxpCheckDatatypeConversion_NetSlopeChangeHWRndMethod');

                                            if~isempty(parsedOutput)
                                                subCheckResultsMap=containers.Map('KeyType','char','ValueType','any');
                                                for idx=1:numel(parsedOutput.tag)
                                                    subCheck=parsedOutput.tag{idx}.info('SubCheck');
                                                    if~isKey(subCheckResultsMap,subCheck)
                                                        subCheckResultsMap(subCheck)={};
                                                    end
                                                    x=subCheckResultsMap(subCheck);
                                                    x{end+1}=parsedOutput.tag{idx};%#ok<AGROW>
                                                    subCheckResultsMap(subCheck)=x;
                                                end

                                                keys=subCheckResultsMap.keys();
                                                for idx=1:numel(keys)

                                                    ft=ModelAdvisor.FormatTemplate('TableTemplate');
                                                    if numel(results)==0
                                                        ft.setSubTitle(DAStudio.message('ModelAdvisor:engine:FxpCheckDatatypeConversion_Title'));
                                                    end
                                                    ft.setSubResultStatusText(subCheckMessageMap(keys{idx}));
                                                    ft.setSubResultStatus('warn');
                                                    ft.setSubBar(false);
                                                    ft.setColTitles({DAStudio.message('ModelAdvisor:engine:FxpBlockIDCol')});
                                                    for i=1:numel(subCheckResultsMap(keys{idx}))
                                                        item=subCheckResultsMap(keys{idx});
                                                        ft.addRow({item{i}.sid});
                                                    end
                                                    results{end+1}=ft;%#ok<AGROW>
                                                end
                                            else
                                                ft=ModelAdvisor.FormatTemplate('TableTemplate');
                                                ft.setSubTitle(DAStudio.message('ModelAdvisor:engine:FxpCheckDatatypeConversion_Title'));
                                                ft.setSubResultStatus('pass');
                                                results=ft;
                                            end



                                            function results=getResultsFixptUnaryRelop(system)

                                                parsedOutput=Advisor.RegisterCGIRInspectorResults.getInstance.parseCGIRResults('LISTENER_FIXPT_RELOP',true,system);
                                                ft=ModelAdvisor.FormatTemplate('TableTemplate');
                                                ft.setSubTitle(DAStudio.message('ModelAdvisor:engine:FxpCheckUnaryRelop_Title'));
                                                if~isempty(parsedOutput)

                                                    ft.setSubResultStatus('warn');
                                                    ft.setSubResultStatusText(DAStudio.message('ModelAdvisor:engine:FxpCheckUnaryRelop'));
                                                    ft.setSubBar(false);
                                                    ft.setColTitles({DAStudio.message('ModelAdvisor:engine:FxpBlockIDCol'),...
                                                    DAStudio.message('ModelAdvisor:engine:FxpCompOpCol')});
                                                    for idx=1:numel(parsedOutput.tag)
                                                        ft.addRow({parsedOutput.tag{idx}.sid,...
                                                        parsedOutput.tag{idx}.info('FunctionName')});
                                                    end
                                                else
                                                    ft.setSubResultStatus('pass');
                                                end
                                                results=ft;


                                                function results=getResultsFixptEmulatedTypes(system)

                                                    parsedOutput=Advisor.RegisterCGIRInspectorResults.getInstance.parseCGIRResults('NODE_EMULATED_WORDLENGTH',true,system);

                                                    if~isempty(parsedOutput)&&numel(parsedOutput.tag)>=2
                                                        parsedOutput=collapseBlkResults(parsedOutput);
                                                    end

                                                    ft=ModelAdvisor.FormatTemplate('TableTemplate');
                                                    ft.setSubTitle(DAStudio.message('ModelAdvisor:engine:FxpCheckEmulationWordlength_Title'));
                                                    if~isempty(parsedOutput)

                                                        ft.setSubResultStatus('warn');
                                                        ft.setInformation(DAStudio.message('ModelAdvisor:engine:CheckEmulationWordlength'));
                                                        ft.setSubBar(false);
                                                        ft.setColTitles({DAStudio.message('ModelAdvisor:engine:FxpBlockIDCol'),...
                                                        DAStudio.message('ModelAdvisor:engine:FxpEmulationTypeCol')});
                                                        for idx=1:numel(parsedOutput.tag)
                                                            ft.addRow({parsedOutput.tag{idx}.sid,...
                                                            parsedOutput.tag{idx}.info('EmulatedType')});
                                                        end
                                                    else
                                                        ft.setSubResultStatus('pass');
                                                    end
                                                    results=ft;


                                                    function status=getResultsStatus(resultSet)
                                                        warn=false;
                                                        fail=false;
                                                        for idx=1:numel(resultSet)
                                                            if strcmp(resultSet{idx}.SubResultStatus,'Warn')
                                                                warn=true;
                                                            elseif strcmp(resultSet{idx}.SubResultStatus,'Fail')
                                                                fail=true;
                                                            end
                                                        end

                                                        if fail
                                                            status=false;
                                                        elseif warn
                                                            status=false;
                                                        else
                                                            status=true;
                                                        end



