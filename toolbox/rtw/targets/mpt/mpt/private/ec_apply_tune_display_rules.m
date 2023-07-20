function ec_apply_tune_display_rules(modelName,packageCSCDef)








    ecMasterDisplayTuneRuleList=[];
    configSetHandle=getActiveConfigSet(modelName);
    rtwprivate('rtwattic','AtticData','ecMasterDisplayTuneRuleList',ecMasterDisplayTuneRuleList);
    try
        modelws=get_param(modelName,'ModelWorkspace');
        wList=modelws.whos;
        modelwsList=[];
        for i=1:length(wList)
            modelwsList{i}=wList(i).name;
        end

        paramTuneLevel=get_param(configSetHandle,'ParamTuneLevel');
        signalDisplayLevel=get_param(configSetHandle,'SignalDisplayLevel');
        signalFlag=0;
        paramFlag=0;
        if isempty(paramTuneLevel)==0
            if ischar(paramTuneLevel)
                paramTuneLevelValue=str2num(paramTuneLevel);
                if isempty(paramTuneLevelValue)==1
                    paramFlag=1;
                end
            else
                paramTuneLevelValue=paramTuneLevel;
            end
        else
            paramFlag=1;
        end
        if isempty(signalDisplayLevel)==0
            if ischar(signalDisplayLevel)
                signalDisplayLevelValue=str2num(signalDisplayLevel);
                if isempty(signalDisplayLevelValue)==1
                    signalFlag=1;
                end
            else
                signalDisplayLevelValue=signalDisplayLevel;
            end
        else
            signalFlag=1;
        end


























        if(paramFlag==0)||(signalFlag==0)
            ddName=get_param(modelName,'DataDictionary');
            ddVarNum=0;
            if isempty(ddName)
                dd=[];
                list=evalin('base','who');
            else

                dd=Simulink.dd.open(ddName);

                signals=dd.getEntriesWithClass('Design_Data','mpt.Signal');
                params=dd.getEntriesWithClass('Design_Data','mpt.Parameter');
                list={signals{:},params{:}};
                ddVarNum=numel(list);
                if slfeature('SLModelAllowedBaseWorkspaceAccess')>0&&...
                    strcmp(get_param(modelName,'HasAccessToBaseWorkspace'),'on')

                    listBWS=evalin('base','who');

                    listBWS=setdiff(listBWS,list);


                    list={list{:},listBWS{:}};
                end
            end

            for i=1:length(list)
                try
                    name=list{i};
                    if isempty(modelwsList)||ismember(name,modelwsList)==0


                        if i>ddVarNum
                            obj=evalin('base',name);
                        else
                            obj=dd.getEntry(['Design_Data.',name]);
                        end








                        if isa(obj,'mpt.Signal')




                            if signalFlag==0

                                baseStorageClass=obj.CoderInfo.StorageClass;
                                if strcmp(baseStorageClass,'Custom')==1
                                    attri=obj.CoderInfo.CustomAttributes.get;
                                    result=ec_get_placement_rules(obj,attri,packageCSCDef);
                                    switch(result.mode)
                                    case{'None','#Define','Include'}
                                    case 'Data'

                                        if isfield(attri,'PersistenceLevel')
                                            persistenceLevel=obj.CoderInfo.CustomAttributes.PersistenceLevel;
                                        else
                                            persistenceLevel=[];
                                        end
                                        if persistenceLevel>signalDisplayLevelValue
                                            set_data_info(name,'StorageClass','Auto',modelName);
                                            ecMasterDisplayTuneRuleList{end+1}=name;
                                        end
                                    otherwise
                                    end
                                end
                            end
                        elseif isa(obj,'mpt.Parameter')

                            if paramFlag==0

                                baseStorageClass=obj.CoderInfo.StorageClass;
                                if strcmp(baseStorageClass,'Custom')==1
                                    attri=obj.CoderInfo.CustomAttributes.get;
                                    result=ec_get_placement_rules(obj,attri,packageCSCDef);
                                    switch(result.mode)
                                    case{'None','#Define','Include'}
                                    case 'Data'

                                        if isfield(attri,'PersistenceLevel')
                                            persistenceLevel=obj.CoderInfo.CustomAttributes.PersistenceLevel;
                                        else
                                            persistenceLevel=[];
                                        end
                                        if persistenceLevel>paramTuneLevelValue
                                            set_data_info(name,'StorageClass','Auto',modelName);
                                            ecMasterDisplayTuneRuleList{end+1}=name;
                                        end
                                    otherwise
                                    end
                                end
                            end

                        else

                        end
                    end
                catch
                    errorFound=1;
                end
            end
        end
    catch
    end
    rtwprivate('rtwattic','AtticData','ecMasterDisplayTuneRuleList',ecMasterDisplayTuneRuleList);
