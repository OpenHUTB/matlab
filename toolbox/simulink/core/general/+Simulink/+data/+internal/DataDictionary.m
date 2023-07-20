classdef DataDictionary<Simulink.data.internal.DataSource





    properties(Hidden)
Dictionary
    end


    methods(Access=public)

        function variableNamesInDD=captureVariableNamesInDD(~,captureLatest,varIds)



            if nargin<2
                varIds=Simulink.data.VariableIdentifier.empty(0,0);
            end
            persistent capturedVariableNamesInDD;
            if isempty(capturedVariableNamesInDD)||captureLatest
                capturedVariableNamesInDD(1).Capture=true;
                capturedVariableNamesInDD(1).CapturedVariableNames={varIds.Name};
            end
            variableNamesInDD=capturedVariableNamesInDD;
        end


        function variableValuesInDD=captureVariableValuesInDD(obj,captureLatest,varIds,resetFlag)




            persistent capturedVariableValuesInDD;
            if resetFlag
                capturedVariableValuesInDD=struct('VarId',{},...
                'Name','',...
                'Value',{});
            end
            if isempty(capturedVariableValuesInDD)||captureLatest
                for i=1:numel(varIds)
                    varId=varIds(i);
                    try


                        if obj.isVariableVisible(varId)
                            varName=varId.Name;
                            varValueTemp=obj.getVariable(varId);
                            if isa(varName,'handle')

                                varValue=copy(varValue);
                            else
                                varValue=varValueTemp;
                            end
                            s=struct('VarId',{varId},...
                            'Name',varName,...
                            'Value',{varValue});
                            capturedVariableValuesInDD(end+1)=s;%#ok<*AGROW>
                        end
                    catch
                    end
                end
            end
            variableValuesInDD=capturedVariableValuesInDD;
        end


        function obj=DataDictionary(sourceId)
            obj.IsPersistent=true;
            obj.DataSourceId=sourceId;
            obj.Dictionary=Simulink.data.dictionary.open(sourceId);
        end


        function identifyVisibleVariables(~)
            assert(true,'Functionality has been replaced by new API');
        end

        function identifyVisibleVariablesByClass(~,~)
            assert(true,'Functionality has been replaced by new API');
        end


        function varIDs=identifyVisibleVariablesDerivedFromClass(obj,baseClassType)


            varIDs=Simulink.data.VariableIdentifier.empty(0,0);
            baseClassInfo=meta.class.fromName(baseClassType);
            assert(~isempty(baseClassInfo),'Unsupported class type: %s\n',baseClassType);

            obj.establishDictionaryConnectionIfClosed;
            if~obj.Dictionary.isOpen
                return;
            end

            ddSection=obj.Dictionary.getSection('Design Data');
            allEntries=ddSection.find('-value','-isa',baseClassType);
            varIDs=obj.createVarIdsFromEntries(allEntries);
        end


        function identifyByName(~,~)
            assert(true,'Functionality has been replaced by new API');
        end


        function isVisible=isVariableVisible(obj,varId)
            obj.establishDictionaryConnectionIfClosed;
            if~obj.Dictionary.isOpen


                return;
            end
            ddSection=obj.Dictionary.getSection('Design Data');
            isVisible=ddSection.exist(varId.Name,'DataSource',varId.DataSourceId);
        end


        function value=getVariable(obj,varID)
            obj.establishDictionaryConnectionIfClosed;
            if~obj.Dictionary.isOpen


                return;
            end
            ddSection=obj.Dictionary.getSection('Design Data');
            entryObj=ddSection.getEntry(varID.VariableIdWithinSource,'DataSource',varID.DataSourceId);
            value=entryObj.getValue;
        end


        function[varID,isCreatedInPersistentSource]=createVariable(obj,variableName,value)
            [~,fileName,ext]=fileparts(obj.DataSourceId);
            dataSourceId=[fileName,ext];
            tmpVarId=Simulink.data.VariableIdentifier(variableName,variableName,...
            dataSourceId);
            nameExists=obj.isVariableVisible(tmpVarId);
            assert(~nameExists,['Variable ',variableName,' exists in the data dictionary']);

            obj.establishDictionaryConnectionIfClosed;
            if~obj.Dictionary.isOpen


                return;
            end

            isCreatedInPersistentSource=true;
            ddSec=obj.Dictionary.getSection('Design Data');

            ddSec.addEntry(variableName,value);
            varID=tmpVarId;
        end


        function success=updateVariable(obj,varID,value)
            success=false;
            obj.establishDictionaryConnectionIfClosed;
            if~obj.Dictionary.isOpen
                return;
            end
            ddSection=obj.Dictionary.getSection('Design Data');
            entryObj=ddSection.getEntry(varID.VariableIdWithinSource,'DataSource',varID.DataSourceId);
            entryObj.setValue(value);
            success=true;
        end


        function success=deleteVariable(obj,varID)
            success=false;
            obj.establishDictionaryConnectionIfClosed;
            if~obj.Dictionary.isOpen
                return;
            end
            try
                ddSection=obj.Dictionary.getSection('Design Data');
                entryObj=ddSection.getEntry(varID.VariableIdWithinSource,'DataSource',varID.DataSourceId);
                entryObj.deleteEntry;
                success=true;
            catch
            end
        end


        function success=save(obj)
            success=false;
            obj.establishDictionaryConnectionIfClosed;
            if~obj.Dictionary.isOpen
                return;
            end
            try
                if obj.Dictionary.HasUnsavedChanges
                    obj.Dictionary.saveChanges;
                end
                success=true;
            catch
            end
        end


        function success=revert(obj)
            success=false;
            obj.establishDictionaryConnectionIfClosed;
            if~obj.Dictionary.isOpen
                return;
            end
            try
                if obj.Dictionary.HasUnsavedChanges
                    obj.Dictionary.discardChanges;
                end
                success=true;
            catch
            end
        end


        function showVariableInUI(obj,varId)
            ddConn=Simulink.dd.open(obj.DataSourceId);
            assert(~isempty(ddConn),'Failed to open dictionary');

            showResolved=true;
            DAStudio.Dialog(Simulink.dd.EntryDDGSource(ddConn,['Design_Data.',varId.Name],showResolved),...
            varId.Name,'DLG_STANDALONE');
        end


        function openBusEditor(obj,varId)
            obj.establishDictionaryConnectionIfClosed;
            if~obj.Dictionary.isOpen
                return;
            end

            buseditor('Create',varId.Name,Simulink.data.DataDictionary(varId.DataSourceId));
        end


        function showVariableInModelExplorer(obj,variableId)
            if~strcmp(obj.DataSourceId,variableId.DataSourceId)
                ddConn=Simulink.dd.open(obj.DataSourceId);
                assert(~isempty(ddConn),'Failed to open dictionary');

                ddClosureList=ddConn.DependencyClosure;
                ddConn.close;
                isFoundVector=strfind(ddClosureList,variableId.getDataSourceFriendlyName);
                index=~cellfun('isempty',isFoundVector);
                fullPath=ddClosureList{index};
            else
                fullPath=obj.Dictionary.filepath;
            end

            slprivate('exploreListNode',fullPath,'dictionary',variableId.Name);
        end


        function captureVariableValues(obj,varIds,resetFlag)
            vars=obj.captureVariableValuesInDD(true,varIds,resetFlag);%#ok<*NASGU>
        end


        function captureVisibleVariableNames(obj,ddVarIds)
            varNames=obj.captureVariableNamesInDD(true,ddVarIds);%#ok<*NASGU>
        end


        function restoreCapturedVariableValues(obj)
            vars=obj.captureVariableValuesInDD(false,[],false);
            for i=1:numel(vars)
                var=vars(i);
                ddObj=Simulink.data.dictionary.open(var(1).VarId(1).getDataSourceFriendlyName);
                ddSection=ddObj.getSection('Design Data');
                if ddSection.exist(var(1).Name)
                    entryObj=ddSection.find('Name',var(1).Name);
                    entryObj.setValue(var(1).Value);
                else
                    ddSection.addEntry(var(1).Name,var(1).Value);
                end
            end
        end


        function removeCruft(obj,ddVarIds)
            currentVarList={ddVarIds.Name};
            lastSavedVarList=obj.captureVariableNamesInDD(false).CapturedVariableNames;
            varsToDelete=setdiff(currentVarList,lastSavedVarList);


            if~isempty(varsToDelete)
                ddSection=obj.Dictionary.getSection('Design Data');
                for i=1:numel(varsToDelete)
                    entryObj=ddSection.find('Name',varsToDelete{i});
                    if~isempty(entryObj)
                        entryObj.deleteEntry;
                    end
                end
            end
        end


        function varExist=hasVariable(obj,varName)
            obj.establishDictionaryConnectionIfClosed;
            if~obj.Dictionary.isOpen


                return;
            end
            ddSection=obj.Dictionary.getSection('Design Data');
            varExist=ddSection.exist(varName);
        end
    end


    methods(Access=private)
        function establishDictionaryConnectionIfClosed(obj)
            if~obj.Dictionary.isOpen
                try
                    obj.Dictionary=Simulink.data.dictionary.open(obj.DataSourceId);
                catch
                end
            end
        end

        function varIDs=createVarIdsFromEntries(~,allEntries)

            varIDs=Simulink.data.VariableIdentifier.empty(0,0);
            for idx=1:length(allEntries)
                varIDs(idx)=...
                Simulink.data.VariableIdentifier(allEntries(idx).Name,...
                allEntries(idx).Name,...
                allEntries(idx).DataSource);
            end
            varIDs=varIDs';
        end
    end
end


