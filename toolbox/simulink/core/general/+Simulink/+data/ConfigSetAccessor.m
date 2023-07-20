classdef ConfigSetAccessor<handle




    properties
Context
ContextScope
    end
    methods(Access=private)
        function csNames=getConfigSetNamesDefinedInModel(obj)
            csNames={};
            csNames=getConfigSets(obj.Context);
        end

        function cs=getSpecificConfigSetDefinedInModel(obj,csName)

            cs=getConfigSet(obj.Context,csName);
        end

        function dataSourceType=getDataSourceType(obj,dataSourceId)
            slRoot=slroot;
            if slRoot.isValidSlObject(dataSourceId)
                dataSourceType='MODEL';
            else
                [~,~,ext]=fileparts(dataSourceId);
                if strcmp(ext,'.sldd')
                    dataSourceType='DICTIONARY';
                else
                    dataSourceType='BASE';
                end
            end
        end

    end

    methods(Access=public)

        function csIds=identifyVisibleConfigSets(obj,restrictToUseable)
            if(nargin<2)
                restrictToUseable=true;
            end
            csIds=Simulink.data.VariableIdentifier.empty(0,0);

            if strcmp(obj.ContextScope,'Model')
                if restrictToUseable
                    csNames=getConfigSetNamesDefinedInModel(obj);

                    for i=1:length(csNames)
                        name=csNames{i};
                        dataSourceId=obj.Context;
                        csIds(i)=Simulink.data.VariableIdentifier(name,name,dataSourceId);
                    end
                else

                    csIdsFromDD=Simulink.data.VariableIdentifier.empty(0,0);
                    ddForModel=get_param(obj.Context,'DataDictionary');


                    ddObj=Simulink.data.dictionary.open(ddForModel);
                    configSecObj=ddObj.getSection('Configurations');
                    csVarsFromDD=configSecObj.evalin('whos');
                    csNamesFromDD={};
                    for idx=1:length(csVarsFromDD)
                        if(strcmp(csVarsFromDD(idx).class,'Simulink.ConfigSet')||...
                            strcmp(csVarsFromDD(idx).class,'Simulink.ConfigSetRef')||...
                            strcmp(csVarsFromDD(idx).class,'Simulink.VariantConfigurationData'))
                            csNamesFromDD{end+1}=csVarsFromDD(idx).name;%#ok
                        end
                    end
                    for i=1:length(csNamesFromDD)
                        name=csNamesFromDD{i};
                        if configSecObj.exist(name)&&~evalin('base',['exist(''',name,''')'])
                            dataSourceId=ddForModel;
                            csIdsFromDD(end+1)=Simulink.data.VariableIdentifier(name,name,dataSourceId);%#ok
                        end
                    end


                    csIdsFromBWS=Simulink.data.VariableIdentifier.empty(0,0);
                    modelAccessToBWS=strcmp(get_param(obj.Context,'HasAccessToBaseWorkspace'),'on');
                    if modelAccessToBWS
                        csVarsFromBWS=evalin('base','whos');
                        csNamesFromBWS={};
                        for idx=1:length(csVarsFromBWS)
                            if(strcmp(csVarsFromBWS(idx).class,'Simulink.ConfigSet')||...
                                strcmp(csVarsFromBWS(idx).class,'Simulink.ConfigSetRef')||...
                                strcmp(csVarsFromBWS(idx).class,'Simulink.VariantConfigurationData'))
                                csNamesFromBWS{end+1}=csVarsFromBWS(idx).name;%#ok
                            end
                        end
                        for i=1:length(csNamesFromBWS)
                            name=csNamesFromBWS{i};
                            dataSourceId='base workspace';
                            csIdsFromBWS(end+1)=Simulink.data.VariableIdentifier(name,name,dataSourceId);%#ok
                        end
                    end
                    csIds=[csIds,csIdsFromBWS,csIdsFromDD];
                end
            end
        end

        function csIds=identifyByName(obj,name,restrictToUseable)
            if(nargin<3)
                restrictToUseable=true;
            end
            csIds=Simulink.data.VariableIdentifier.empty(0,0);

            if strcmp(obj.ContextScope,'Model')
                if restrictToUseable
                    cs=getSpecificConfigSetDefinedInModel(obj,name);
                    if~isempty(cs)
                        dataSourceId=obj.Context;
                        csIds=Simulink.data.VariableIdentifier(name,name,dataSourceId);
                    end
                else
                    allCsIds=obj.identifyVisibleConfigSets(false);
                    for idx=1:length(allCsIds)
                        csId=allCsIds(idx);
                        if strcmp(csId.Name,name)
                            csIds=[csIds,csId];%#ok
                        end
                    end
                end
            end
        end

        function cs=getConfigSetObj(obj,csId,restrictToUseable)

            if(nargin<3)
                restrictToUseable=true;
            end
            if strcmp(obj.ContextScope,'Model')
                if restrictToUseable

                    cs=getSpecificConfigSetDefinedInModel(obj,csId.Name);
                else

                    dataSourceId=csId.DataSourceId;

                    if strcmp(dataSourceId,'base workspace')
                        cs=evalin('base',csId.Name);
                    else
                        dd=Simulink.data.dictionary.open(dataSourceId);
                        ddSection=dd.getSection('Configurations');
                        csEntry=ddSection.getEntry(csId.Name);
                        cs=csEntry.getValue();
                    end
                end
            end
        end

        function[underLyingCSObj,underLyingCsId]=getUnderlyingConfigSetObj(obj,csId,restrictToUseable)
            if(nargin<3)
                restrictToUseable=true;
            end
            underLyingCsId=Simulink.data.VariableIdentifier.empty(0,0);
            underLyingCSObj=[];
            if restrictToUseable
                cs=obj.getSpecificConfigSetDefinedInModel(csId.Name);
            else
                cs=obj.getConfigSetObj(csId,false);
            end

            if isa(cs,'Simulink.ConfigSet')||isa(cs,'Simulink.VariantConfigurationData')
                underLyingCsId=csId;
                underLyingCSObj=cs;
            elseif isa(cs,'Simulink.ConfigSetRef')
                cs.refresh(true);
                underlyingName=cs.SourceName;
                if~isempty(underlyingName)




                    if(evalin('base',sprintf('exist(''%s'')',underlyingName)))
                        dataSourceId='base workspace';
                        if restrictToUseable
                            underLyingCSObj=cs.getResolvedConfigSetCopy;
                            underLyingCsId=Simulink.data.VariableIdentifier(cs.getRefConfigSetName,cs.getRefConfigSetName,dataSourceId);
                        else
                            underLyingCSObj=getConfigurationsItem(cs.SourceName,'base');
                            underLyingCsId=Simulink.data.VariableIdentifier(cs.SourceName,cs.SourceName,dataSourceId);
                        end
                    else
                        if restrictToUseable
                            dataSourceId=cs.DDName;
                            underLyingCSObj=cs.getResolvedConfigSetCopy;
                            underLyingCsId=Simulink.data.VariableIdentifier(cs.getRefConfigSetName,cs.getRefConfigSetName,dataSourceId);
                        else
                            dataSourceId=csId.getDataSourceFriendlyName;
                            underLyingCSObj=getConfigurationsItem(cs.SourceName,csId.getDataSourceFriendlyName);
                            underLyingCsId=Simulink.data.VariableIdentifier(cs.SourceName,cs.SourceName,dataSourceId);
                        end
                    end
                end
            end
        end

        function success=updateConfigSet(obj,csId,updatedObj)
            dataSourceId=csId.DataSourceId;
            name=csId.Name;
            success=true;
            try
                dataSourceType=obj.getDataSourceType(dataSourceId);
                switch dataSourceType
                case 'MODEL'
                    detachConfigSet(obj.Context,csId.Name);
                    attachConfigSet(obj.Context,updatedObj);
                case 'DICTIONARY'

                    dd=Simulink.data.dictionary.open(dataSourceId);
                    ddSection=dd.getSection('Configurations');
                    entryObj=ddSection.getEntry(csId.Name);
                    entryObj.deleteEntry;
                    ddSection.addEntry(csId.Name,updatedObj);
                otherwise

                    assignin('base',name,updatedObj);
                end
            catch MException
                success=false;
            end
        end

        function success=deleteConfigSet(obj,csId)
            dataSourceId=csId.DataSourceId;
            try
                success=true;
                dataSourceType=obj.getDataSourceType(dataSourceId);
                switch dataSourceType
                case 'MODEL'
                    detachConfigSet(obj.Context,csId.Name);
                case 'DICTIONARY'

                    dd=Simulink.data.dictionary.open(dataSourceId);
                    ddSection=dd.getSection('Configurations');
                    entryObj=ddSection.getEntry(csId.Name);
                    entryObj.deleteEntry;
                otherwise

                    evalStr=sprintf('clear %s',csId.Name);
                    evalin('base',evalStr);
                end
            catch MException
                success=false;
            end
        end

    end

    methods(Access=public,Static)
        function obj=create(context)
            slRoot=slroot;
            assert(slRoot.isValidSlObject(context),'Only Simulink Models can be supplied as valid Contexts');
            obj=Simulink.data.ConfigSetAccessor;
            obj.Context=context;
            obj.ContextScope='Model';
        end
    end
end


