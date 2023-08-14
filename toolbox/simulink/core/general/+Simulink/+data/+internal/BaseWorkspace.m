classdef BaseWorkspace<Simulink.data.internal.DataSource




    properties(Access=private)
        BWSBackingFile='';
    end

    methods(Access=public)

        function variableNamesInBWS=captureVariableNamesInBWS(obj,captureLatest)



            persistent capturedVariableNamesInBWS;
            if captureLatest
                capturedVariableNamesInBWS=struct('Capture','',...
                'CapturedVariableNames',{});
            end
            if isempty(capturedVariableNamesInBWS)||captureLatest
                capturedVariableNamesInBWS(1).Capture=true;
                capturedVariableNamesInBWS(1).CapturedVariableNames={obj.identifyVisibleVariables.Name};
            end
            variableNamesInBWS=capturedVariableNamesInBWS;
        end


        function variableValuesInBWS=captureVariableValuesInBWS(obj,captureLatest,varIds)




            persistent capturedVariableValuesInBWS;
            if isempty(capturedVariableValuesInBWS)||captureLatest
                capturedVariableValuesInBWS=struct('VarId',{},...
                'Name','',...
                'Value',{});
                for i=1:numel(varIds)
                    varId=varIds(i);
                    if obj.isVariableVisible(varId)
                        varName=varId.Name;
                        try
                            varValueTemp=obj.getVariable(varId);
                            if isa(varId.Name,'handle')
                                varValue=copy(varValue);
                            else
                                varValue=varValueTemp;
                            end
                        catch me %#ok
                        end
                        s=struct('VarId',{varId},...
                        'Name',varName,...
                        'Value',{varValue});
                        capturedVariableValuesInBWS(end+1)=s;%#ok<*AGROW>
                    end
                end
            end
            variableValuesInBWS=capturedVariableValuesInBWS;
        end


        function obj=BaseWorkspace()
            obj.IsPersistent=false;
            obj.DataSourceId='base workspace';
        end


        function varIDs=identifyVisibleVariables(obj)
            allVars=evalin('base','builtin(''whos'')');

            varIDs=Simulink.data.VariableIdentifier.empty(0,0);
            for idx=1:length(allVars)
                varIDs(idx)=...
                Simulink.data.VariableIdentifier(allVars(idx).name,...
                allVars(idx).name,...
                obj.DataSourceId);
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
            allVars=evalin('base','builtin(''whos'')');
            lastIdx=1;
            for idx=1:length(allVars)
                classInfo=meta.class.fromName(allVars(idx).class);
                if~isempty(classInfo)&&(classInfo==baseClassInfo)
                    varIDs(lastIdx)=...
                    Simulink.data.VariableIdentifier(allVars(idx).name,...
                    allVars(idx).name,...
                    obj.DataSourceId);%#ok
                    lastIdx=lastIdx+1;
                end
            end
            varIDs=varIDs';
        end


        function varIDs=identifyVisibleVariablesDerivedFromClass(obj,baseClassType)

            baseClassInfo=meta.class.fromName(baseClassType);
            assert(~isempty(baseClassInfo),'Unsupported class type: %s\n',baseClassType);
            varIDs=Simulink.data.VariableIdentifier.empty(0,0);
            allVars=evalin('base','builtin(''whos'')');
            lastIdx=1;
            for idx=1:length(allVars)
                classInfo=meta.class.fromName(allVars(idx).class);
                if~isempty(classInfo)&&(classInfo<=baseClassInfo)
                    varIDs(lastIdx)=...
                    Simulink.data.VariableIdentifier(allVars(idx).name,...
                    allVars(idx).name,...
                    obj.DataSourceId);%#ok
                    lastIdx=lastIdx+1;
                end
            end
            varIDs=varIDs';
        end


        function varIDs=identifyByName(obj,varName)
            varIDs=Simulink.data.VariableIdentifier.empty(0,0);
            status=evalin('base',sprintf('builtin(''exist'',''%s'', ''var'') > 0;',varName));
            if status
                varIDs(1)=...
                Simulink.data.VariableIdentifier(varName,...
                varName,...
                obj.DataSourceId);
            end
        end


        function isVisible=isVariableVisible(obj,varId)
            isVisible=strcmp(varId.DataSourceId,obj.DataSourceId)&&obj.hasVariable(varId.VariableIdWithinSource);
        end


        function value=getVariable(obj,varID)
            assert(strcmp(varID.DataSourceId,obj.DataSourceId))
            varName=varID.VariableIdWithinSource;
            value=evalin('base',varName);
        end


        function[varID,isCreatedInPersistentSource]=createVariable(obj,variableName,value)
            doesNotExists=isempty(obj.identifyByName(variableName));
            assert(doesNotExists,['Variable ',variableName,' exists in the base workspace']);

            assignin('base',variableName,value);
            varID=obj.identifyByName(variableName);
            isCreatedInPersistentSource=false;
        end


        function success=updateVariable(obj,varID,value)
            success=false;
            assert(strcmp(varID.DataSourceId,obj.DataSourceId))
            varName=varID.VariableIdWithinSource;
            try
                assignin('base',varName,value);
                success=true;
            catch
            end
        end


        function success=deleteVariable(obj,varID)
            success=false;
            assert(strcmp(varID.DataSourceId,obj.DataSourceId))
            varName=varID.VariableIdWithinSource;
            evalStr=sprintf('clear %s',varName);
            try
                evalin('base',evalStr);
                success=true;
            catch
            end
        end

        function setBWSBackingFile(obj,bwsBackingFileName)
            obj.BWSBackingFile=bwsBackingFileName;
        end

        function success=save(obj)
            success=false;
            if~isempty(obj.BWSBackingFile)

                warningVar=warning('query','all');
                warning('off','all');

                evalin('base',sprintf('save %s %s',obj.BWSBackingFile));
                warning(warningVar);

                success=true;
            end
        end

        function success=revert(obj)
            success=false;
            if~isempty(obj.BWSBackingFile)

                evalin('base','clear;');


                warningVar=warning('query','all');
                warning('off','all');

                evalin('base',sprintf('load(''%s'')',obj.BWSBackingFile));
                warning(warningVar);
                success=true;
            end
        end


        function showVariableInUI(obj,varId)
            assert(strcmp(varId.DataSourceId,obj.DataSourceId))

            dataObj=obj.getVariable(varId);
            if isobject(dataObj)||isa(dataObj,'handle')||isa(dataObj,'handle.handle')
                DAStudio.Dialog(dataObj,varId.Name,'DLG_STANDALONE');
            else
                slprivate('showWorkspaceVar','base',varId.Name,'');
            end
        end


        function openBusEditor(obj,varId)
            assert(strcmp(varId.DataSourceId,obj.DataSourceId));
            buseditor('Create',varId.Name);
        end


        function showVariableInModelExplorer(obj,variableId)
            assert(strcmp(variableId.DataSourceId,obj.DataSourceId));

            slprivate('exploreListNode','','base',variableId.Name);
        end


        function captureVariableValues(obj,varIds)
            vars=obj.captureVariableValuesInBWS(true,varIds);%#ok<*NASGU>
        end


        function restoreCapturedVariableValues(obj)
            vars=obj.captureVariableValuesInBWS(false,[]);
            for i=1:numel(vars)
                var=vars(i);
                assignin('base',var(1).Name,var(1).Value);
            end
        end


        function captureVisibleVariableNames(obj)
            varNames=obj.captureVariableNamesInBWS(true);%#ok<*NASGU>
        end


        function removeCruft(obj)
            currentVarList={obj.identifyVisibleVariables.Name};
            lastSavedVarList=obj.captureVariableNamesInBWS(false).CapturedVariableNames;
            varsToDelete=setdiff(currentVarList,lastSavedVarList);


            if~isempty(varsToDelete)
                evalin('base',['clear ',strjoin(varsToDelete,' ')]);
            end
        end


        function varExist=hasVariable(~,varName)
            varExist=evalin('base',sprintf('builtin(''exist'',''%s'', ''var'') > 0;',varName));
        end
    end

    methods(Access=private)
        function varIDs=identifyVariablesByClassName(obj,classType)
            varIDs=Simulink.data.VariableIdentifier.empty(0,0);
            allVars=evalin('base','builtin(''whos'')');
            lastIdx=1;
            for idx=1:length(allVars)
                if strcmp(classType,allVars(idx).class)
                    varIDs(lastIdx)=...
                    Simulink.data.VariableIdentifier(allVars(idx).name,...
                    allVars(idx).name,...
                    obj.DataSourceId);%#ok
                    lastIdx=lastIdx+1;
                end
            end
            varIDs=varIDs';
        end
    end
end


