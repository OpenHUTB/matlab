function[ResultDescription,ResultHandles]=execCheckStowawayDoubles(system)





    ResultDescription={};
    ResultHandles={};

    mdladvObj=Simulink.ModelAdvisor.getModelAdvisor(system);

    mdladvObj.setCheckResultStatus(false);

    ResultDescription=addResults(@getModelSettingResults,ResultDescription,mdladvObj);
    ResultDescription=addResults(@getResultsStowawayDouble,ResultDescription,mdladvObj);


    mdladvObj.setCheckResultStatus(getResultsStatus(ResultDescription{1})...
    &&getResultsStatus(ResultDescription{2}));

    function results=addResults(fcn,res,mdladvObj)
        results=res;
        currentResults=fcn(mdladvObj);
        if isempty(currentResults)
            return;
        end
        if iscell(currentResults)
            for i=1:numel(currentResults)
                results{end+1}=currentResults{i};%#ok
            end
        else
            results{end+1}=currentResults;
        end

        function results=getResultsStowawayDouble(mdladvObj)
            parsedOutput=Advisor.RegisterCGIRInspectorResults.getInstance.parseCGIRResults('NODE_STOWAWAY_DOUBLE');

            ft=ModelAdvisor.FormatTemplate('ListTemplate');
            ft.setSubTitle(DAStudio.message('ModelAdvisor:engine:CheckStowawayDouble_Title'));
            ft.setInformation(DAStudio.message('ModelAdvisor:engine:CheckStowawayDouble'));
            objs={};
            if~isempty(parsedOutput)
                selectedSUD=mdladvObj.getSelectedSystem;
                selectedSystemSID=Simulink.ID.getSID(selectedSUD);
                for idx=1:numel(parsedOutput.tag)
                    if findInScopeOf(selectedSystemSID,parsedOutput.tag{idx}.sid)

                        objs{end+1}=parsedOutput.tag{idx}.sid;%#ok
                    end
                end
            end
            if~isempty(objs)

                ft.setSubResultStatus('warn');
                ft.setSubResultStatusText(DAStudio.message('ModelAdvisor:engine:CheckStowawayDoubleWarn'));
                ft.setListObj(objs);
                results=ft;
                return;
            end


            ft.setSubResultStatus('pass');
            ft.setSubResultStatusText(DAStudio.message('ModelAdvisor:engine:CheckStowawayDoublePass'));
            results=ft;









            function ft=getModelSettingResults(mdladvObj)

                ft=ModelAdvisor.FormatTemplate('TableTemplate');
                ft.setSubTitle(DAStudio.message('ModelAdvisor:engine:CheckModelSettingForSingleDesign_Title'));
                ft.setInformation(DAStudio.message('ModelAdvisor:engine:CheckModelSettingForSingleDesign'));


                params={'BooleanDataType','DefaultUnderspecifiedDataType','TargetLangStandard'};

                settings={'off','on','double','single','C89/C90 (ANSI)','C99 (ISO)'};


                [allRefMdls,modelSettings,warn]=checkModelSettings(mdladvObj,params,settings);

                if warn

                    ft.setSubResultStatus('warn');

                    ft.setSubResultStatusText(DAStudio.message('ModelAdvisor:engine:CheckModelSettingForSingleDesignWarn'));

                    ft.setColTitles({DAStudio.message('ModelAdvisor:engine:CheckModelSettingForSingleDesignCol0')...
                    ,DAStudio.message('ModelAdvisor:engine:CheckModelSettingForSingleDesignCol1'),...
                    DAStudio.message('ModelAdvisor:engine:CheckModelSettingForSingleDesignCol2'),...
                    DAStudio.message('ModelAdvisor:engine:CheckModelSettingForSingleDesignCol3')});


                    for i=numel(allRefMdls):-1:1
                        modelName=allRefMdls{i};
                        encodedModelName=getEncodedModelName(modelName);
                        if modelSettings{i}.logicalDTOff
                            ft.addRow({modelName,DAStudio.message('ModelAdvisor:engine:LogicalDTSetting',encodedModelName),settings{1},settings{2}});
                            modelName='';
                        end
                        if modelSettings{i}.defaultDTDbl
                            ft.addRow({modelName,DAStudio.message('ModelAdvisor:engine:DefaultDTSetting',encodedModelName),settings{3},settings{4}});
                            modelName='';
                        end
                        if modelSettings{i}.isTLSC89To99
                            ft.addRow({modelName,DAStudio.message('ModelAdvisor:engine:TLSSetting',encodedModelName),settings{5},settings{6}});
                        end
                    end
                else

                    ft.setSubResultStatus('pass');
                    ft.setSubResultStatusText(DAStudio.message('ModelAdvisor:engine:CheckModelSettingForSingleDesignPass'));
                end



                function encodedModelName=getEncodedModelName(modelName)
                    encodedModelName=modeladvisorprivate('HTMLjsencode',modelName,'encode');
                    encodedModelName=[encodedModelName{:}];


                    function status=getResultsStatus(resultSet)

                        status=~(strcmp(resultSet.SubResultStatus,'Warn')||...
                        strcmp(resultSet.SubResultStatus,'Fail'));







                        function[allRefMdls,modelSettings,warn]=checkModelSettings(mdladvObj,params,settings)
                            warn=false;

                            if Simulink.internal.useFindSystemVariantsMatchFilter()
                                [allRefMdls,~]=find_mdlrefs(bdroot(mdladvObj.ModelName),...
                                'AllLevels',true,...
                                'IncludeProtectedModels',true,...
                                'MatchFilter',@Simulink.match.activeVariants,...
                                'IncludeCommented','off',...
                                'KeepModelsLoaded',true);
                            else
                                [allRefMdls,~]=find_mdlrefs(bdroot(mdladvObj.ModelName),'AllLevels',true,...
                                'IncludeProtectedModels',true,...
                                'Variants','ActiveVariants',...
                                'IncludeCommented','off',...
                                'KeepModelsLoaded',true);
                            end
                            numModels=numel(allRefMdls);
                            modelSettings=cell(numModels);
                            for i=1:numModels
                                model=allRefMdls{i};

                                modelSettings{i}.logicalDTOff=strcmp(get_param(model,params{1}),settings{1});

                                modelSettings{i}.defaultDTDbl=strcmp(get_param(model,params{2}),settings{3});

                                modelSettings{i}.isTLSC89To99=getIsCheckTLS(model,params{3},settings{5},settings{6});
                                warn=warn||modelSettings{i}.logicalDTOff||modelSettings{i}.defaultDTDbl||modelSettings{i}.isTLSC89To99;
                            end








                            function isTLSC89To99=getIsCheckTLS(model,paramName,C89Str,C99Str)
                                cs=getActiveConfigSet(model);
                                isTLSC89To99=false;

                                if~cs.hasProp(paramName)||~cs.getPropEnabled(paramName)
                                    return
                                end

                                propStruct=configset.getParameterInfo(cs,paramName);
                                if~propStruct.IsReadable
                                    return
                                end

                                isCheckTLS=all(ismember({C89Str,C99Str},propStruct.AllowedValues));
                                isTLSC89To99=isCheckTLS&&strcmp(propStruct.Value,C89Str);




