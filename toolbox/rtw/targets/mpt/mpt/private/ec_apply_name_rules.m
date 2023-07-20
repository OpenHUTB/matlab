function ec_apply_name_rules(modelName,packageCSCDef)










    configSetHandle=getActiveConfigSet(modelName);
    ecMasterNamingRuleList=[];
    rtwprivate('rtwattic','AtticData','ecMasterNamingRuleList',ecMasterNamingRuleList);
    try
        modelws=get_param(modelName,'ModelWorkspace');
        wList=modelws.whos;
        modelwsList=[];
        for i=1:length(wList)
            modelwsList{i}=wList(i).name;
        end






        defineNamingRule=get_param(configSetHandle,'DefineNamingRule');
        paramNamingRule=get_param(configSetHandle,'ParamNamingRule');
        signalNamingRule=get_param(configSetHandle,'SignalNamingRule');

        defineNamingRule_is_None=strcmp(defineNamingRule,'None');
        paramNamingRule_is_None=strcmp(paramNamingRule,'None');
        signalNamingRule_is_None=strcmp(signalNamingRule,'None');

        opFlag=defineNamingRule_is_None&paramNamingRule_is_None&signalNamingRule_is_None;

        if opFlag==0
            defineNamingFcn=strtok(get_param(configSetHandle,'DefineNamingFcn'),'.');
            paramNamingFcn=strtok(get_param(configSetHandle,'ParamNamingFcn'),'.');
            signalNamingFcn=strtok(get_param(configSetHandle,'SignalNamingFcn'),'.');


            infoRecord.modelName=modelName;
            moduleNamingRule=get_param(configSetHandle,'ModuleNamingRule');



            moduleOwner=get_param(configSetHandle,'ModuleName');
            switch(moduleNamingRule)
            case 'Unspecified'
                moduleNameFlag=0;
                moduleOwner='';
            case 'UserSpecified'
                moduleNameFlag=1;
                assert(false,'UserSpecified is deprecated');
            case 'SameAsModel'
                moduleNameFlag=1;
                moduleOwner=modelName;
            otherwise
                moduleNameFlag=0;
                moduleOwner='';
            end
            infoRecord.moduleNameFlag=moduleNameFlag;
            infoRecord.moduleOwner=moduleOwner;%#ok

            ddName=get_param(modelName,'DataDictionary');
            ddVarNum=0;
            if isempty(ddName)
                dd=[];
                list=evalin('base','who');
            else

                dd=Simulink.dd.open(ddName);

                signals=dd.getEntriesWithClass('Design_Data','Simulink.Signal');
                params=dd.getEntriesWithClass('Design_Data','Simulink.Parameter');
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
                        if isa(obj,'Simulink.Signal')
                            approach=signalNamingRule;
                            nameCreateScript=signalNamingFcn;
                            SimulinkDerived=~signalNamingRule_is_None;
                        elseif isa(obj,'Simulink.Parameter')
                            cAttri=obj.CoderInfo.CustomAttributes.get;
                            result=ec_get_placement_rules(obj,cAttri,packageCSCDef);

                            if strcmp(result.mode,'#Define')
                                approach=defineNamingRule;
                                nameCreateScript=defineNamingFcn;
                                SimulinkDerived=~defineNamingRule_is_None;
                            elseif strcmp(result.mode,'Include')&&l_check_customdatainitmacro(obj,packageCSCDef)
                                approach=defineNamingRule;
                                nameCreateScript=defineNamingFcn;
                                SimulinkDerived=~defineNamingRule_is_None;
                            else
                                approach=paramNamingRule;
                                nameCreateScript=paramNamingFcn;
                                SimulinkDerived=~paramNamingRule_is_None;
                            end

                        else
                            SimulinkDerived=0;
                            nameCreateScript='';
                        end
                        if(SimulinkDerived==1)

                            if isempty(obj.CoderInfo.Identifier)&&(strcmp(obj.CoderInfo.StorageClass,'Auto')==0)

                                try
                                    updateFlag=1;
                                    switch(approach)
                                    case 'Custom'
                                        if~exist(nameCreateScript,'file')
                                            DAStudio.error('RTW:mpt:NamingRuleErr',nameCreateScript);
                                        else
                                            revisedName=eval([nameCreateScript,'(''',name,''',infoRecord);']);
                                        end
                                    case 'LowerCase'
                                        revisedName=lower(name);
                                    case 'UpperCase'
                                        revisedName=upper(name);
                                    case 'None'
                                        updateFlag=0;
                                    otherwise
                                        updateFlag=0;
                                    end
                                    if updateFlag==1
                                        if strcmp(revisedName,name)==0
                                            set_data_info(name,'Identifier',revisedName,modelName);
                                            set_data_info(name,'AliasFromNamingRule',true,modelName);
                                            ecMasterNamingRuleList{end+1}=name;
                                        end
                                    end
                                catch ME
                                    rethrow(ME);
                                end
                            end
                        end
                    end
                catch ME
                    rethrow(ME);
                end

            end
        end

    catch ME
        rethrow(ME);
    end
    rtwprivate('rtwattic','AtticData','ecMasterNamingRuleList',ecMasterNamingRuleList);




    function r=l_check_customdatainitmacro(obj,packageCSCDef)

        r=false;

        if~isempty(obj.CoderInfo.StorageClass)&&strcmp(obj.CoderInfo.StorageClass,'Custom')
            cscdef=ec_get_cscdef(obj,packageCSCDef);
            if~isempty(cscdef)&&strcmp(cscdef.DataInit,'Macro')
                r=true;
            end
        end
