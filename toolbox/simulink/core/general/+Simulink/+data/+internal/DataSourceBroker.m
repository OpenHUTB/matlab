classdef DataSourceBroker




    properties(Access=private)
        Broker;
    end

    properties(Access=public)
        IsPersistent;
    end



    methods(Access=public)



        function varIDs=identifyVisibleVariables(obj)
            mdl=mf.zero.Model;

            varList=obj.findData(mdl);
            varIDs=Simulink.data.VariableIdentifier.empty(0,0);
            for idx=1:length(varList)
                varIDs(idx)=Simulink.data.VariableIdentifier(varList(idx).name,...
                varList(idx).name,varList(idx).source);
            end
            varIDs=varIDs';
        end


        function varIDs=identifyVisibleVariablesByClass(obj,classType)

            baseClassInfo=meta.class.fromName(classType);
            if isempty(baseClassInfo)&&strcmp(classType,'Simulink.Variant')


                varIDs=obj.identifyVariablesByClassName(classType);
                return;
            end

            assert(~isempty(baseClassInfo),'Unsupported class type: %s\n',classType);
            varIDs=Simulink.data.VariableIdentifier.empty(0,0);

            mdl=mf.zero.Model;
            varList=obj.findData(mdl);
            lastIdx=1;
            for idx=1:length(varList)

                dataType=class(varList(idx).getMatValue);
                classInfo=meta.class.fromName(dataType);

                if~isempty(classInfo)&&(classInfo==baseClassInfo)
                    varIDs(lastIdx)=Simulink.data.VariableIdentifier(varList(idx).name,...
                    varList(idx).name,varList(idx).source);
                    lastIdx=lastIdx+1;
                end
            end
            varIDs=varIDs';
        end

        function varIDs=identifyVisibleVariablesDerivedFromClass(obj,baseClassType)

            baseClassInfo=meta.class.fromName(baseClassType);
            assert(~isempty(baseClassInfo),'Unsupported class type: %s\n',baseClassType);
            varIDs=Simulink.data.VariableIdentifier.empty(0,0);
            mdl=mf.zero.Model;

            varList=obj.findData(mdl);
            lastIdx=1;
            for idx=1:length(varList)

                dataClassInfo=class(varList(idx).getMatValue);
                classInfo=meta.class.fromName(dataClassInfo);
                if~isempty(classInfo)&&(classInfo<=baseClassInfo)
                    varIDs(lastIdx)=...
                    Simulink.data.VariableIdentifier(varList(idx).name,...
                    varList(idx).name,...
                    varList(idx).source);
                    lastIdx=lastIdx+1;
                end
            end

            varIDs=varIDs';
        end


        function varIDs=identifyByName(obj,varName)
            varIDs=Simulink.data.VariableIdentifier.empty(0,0);
            mdl=mf.zero.Model;

            varInfo=obj.lookupDataByName(varName,mdl);
            for idx=1:length(varInfo)
                varIDs(idx)=Simulink.data.VariableIdentifier(varName,...
                varName,varInfo(idx).source);
            end
            varIDs=varIDs';

        end

        function isVisible=isVariableVisible(obj,varId)

            varName=varId.VariableIdWithinSource;
            isVisible=false;
            mdl=mf.zero.Model;
            source=varId.getDataSourceFriendlyName;
            varInfo=obj.lookupDataByName(varName,mdl);
            for idx=1:length(varInfo)
                if strcmp(varInfo(idx).source,source)
                    isVisible=true;
                    break;
                end
            end
        end

        function value=getVariable(obj,varId)
            varName=varId.VariableIdWithinSource;
            source=varId.getDataSourceFriendlyName;
            mdl=mf.zero.Model;
            varInfo=obj.lookupDataByName(varName,mdl);
            found=false;

            for idx=1:length(varInfo)
                if strcmp(varInfo(idx).source,source)
                    value=varInfo(idx).getMatValue;
                    found=true;
                    break;
                end
            end
            if~found
                DAStudio.error('Simulink:Data:VarNotFound',varName,source);
            end
        end


        function varExist=hasVariable(obj,varName)
            varExist=false;
            mdl=mf.zero.Model;
            dataInfo=obj.lookupDataByName(varName,mdl);
            if~isempty(dataInfo)
                varExist=true;
            end
        end


        function varIDs=identifyVisibleVariablesOfNumericType(obj,types)
            varIDs=Simulink.data.VariableIdentifier.empty(0,0);
            for i=1:length(types)
                newVarIDs=obj.identifyVisibleVariablesDerivedFromClass(types{i});
                varIDs=[varIDs;newVarIDs];%#ok<*AGROW>
            end
        end


        function success=updateVariable(obj,varId,~)
            success=false;%#ok
            varName=varId.Name;
            source=obj.getFileNameFromPath(varId.getDataSourceFriendlyName);


            DAStudio.error('Simulink:Data:UpdateVariableFail',varName,source);
        end

        function[varID,isCreatedInPersistentSource]=createVariable(~,varName,~)
            varID=Simulink.data.VariableIdentifier.empty(0,0);%#ok
            isCreatedInPersistentSource=false;%#ok


            DAStudio.error('Simulink:Data:CreateVariableFail',varName);
        end

        function success=deleteVariable(obj,varId)
            success=false;%#ok
            varName=varId.Name;
            source=obj.getFileNameFromPath(varId.getDataSourceFriendlyName);


            DAStudio.error('Simulink:Data:DeleteVariableFail',varName,source);
        end

        function success=save(~)
            success=false;%#ok


            DAStudio.error('Simulink:Data:SaveAndRevertFail');
        end

        function success=revert(~)
            success=false;%#ok


            DAStudio.error('Simulink:Data:SaveAndRevertFail');
        end

        function showVariableInModelExplorer(obj,varId)
            varName=varId.Name;
            source=obj.getFileNameFromPath(varId.getDataSourceFriendlyName);


            DAStudio.error('Simulink:Data:UIFail',varName,source);
        end

        function openBusEditor(obj,varId)
            varName=varId.Name;
            source=obj.getFileNameFromPath(varId.getDataSourceFriendlyName);


            DAStudio.error('Simulink:Data:UIFail',varName,source);
        end


        function showVariableInUI(obj,varId)
            varName=varId.Name;
            source=obj.getFileNameFromPath(varId.getDataSourceFriendlyName);


            DAStudio.error('Simulink:Data:UIFail',varName,source);
        end

        function captureVariableValues(~,~)


            DAStudio.error('Simulink:Data:CaptureAndRestoreFail');
        end

        function restoreCapturedVariableValues(~)


            DAStudio.error('Simulink:Data:CaptureAndRestoreFail');
        end

        function captureVisibleVariableNames(~)


            DAStudio.error('Simulink:Data:CaptureAndRestoreFail');
        end

        function removeCruft(~)


            DAStudio.error('Simulink:Data:CaptureAndRestoreFail');
        end

        function obj=DataSourceBroker(broker)
            obj.IsPersistent=true;
            obj.Broker=broker;
        end


        function isExist=isSource(obj,sourceName)
            assert(isvalid(obj.Broker),'Broker does not exist');
            brokerConfig=obj.Broker.getActiveBrokerConfig;
            isExist=brokerConfig.isSource(sourceName);
        end

    end


    methods(Access=private)

        function varIDs=identifyVariablesByClassName(obj,classType)
            varIDs=Simulink.data.VariableIdentifier.empty(0,0);
            mdl=mf.zero.Model;
            varList=obj.findData(mdl);

            lastIdx=1;
            for idx=1:length(varList)
                dataClassInfo=class(varList(idx).getMatValue);
                if strcmp(classType,dataClassInfo)
                    varIDs(lastIdx)=...
                    Simulink.data.VariableIdentifier(varList(idx).name,...
                    varList(idx).name,...
                    varList(idx).source);
                    lastIdx=lastIdx+1;
                end
            end
            varIDs=varIDs';
        end


        function varList=findData(obj,mdl)
            brokerObj=obj.Broker;
            assert(isvalid(brokerObj),"Broker does not exist");
            varList=obj.Broker.discoverAllSymbols(mdl);
        end

        function dataInfo=lookupDataByName(obj,varName,mdl)
            assert(isvalid(obj.Broker),"Broker does not exist");
            try


                obj.Broker.updateCache(mdl);
            catch ME
                warning(ME.message);
            end
            dataInfo=obj.Broker.lookupSymbolByNameInAllSources(varName,mdl);
        end

        function fileName=getFileNameFromPath(~,fullspec)
            [~,name,ext]=fileparts(fullspec);
            fileName=[name,ext];
        end

    end
end
