classdef ModelWorkspace<Simulink.data.internal.DataSource






    methods(Access=public)

        function variableNamesInMWS=captureVariableNamesInMWS(obj,captureLatest)



            persistent capturedVariableNamesInMWS;
            if captureLatest
                capturedVariableNamesInMWS=struct('Capture','',...
                'CapturedVariableNames',{});
            end
            if isempty(capturedVariableNamesInMWS)||captureLatest
                capturedVariableNamesInMWS(1).Capture=true;
                capturedVariableNamesInMWS(1).CapturedVariableNames={obj.identifyVisibleVariables.Name};
            end
            variableNamesInMWS=capturedVariableNamesInMWS;
        end


        function variableValuesInMWS=captureVariableValuesInMWS(obj,captureLatest,varIds)




            persistent capturedVariableValuesInMWS;
            if isempty(capturedVariableValuesInMWS)||captureLatest
                capturedVariableValuesInMWS=struct('VarId',{},...
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
                        capturedVariableValuesInMWS(end+1)=s;%#ok<*AGROW>
                    end
                end
            end
            variableValuesInMWS=capturedVariableValuesInMWS;
        end

        function obj=ModelWorkspace(sourceId)
            obj.IsPersistent=true;
            obj.DataSourceId=sourceId;
        end


        function varIDs=identifyVisibleVariables(obj)
            varIDs={};
            if obj.loadDataSource==false
                return;
            end
            mws=get_param(obj.DataSourceId,'ModelWorkspace');
            allVars=mws.whos;
            varIDs=Simulink.data.VariableIdentifier.empty(size(allVars,1),0);
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
            if obj.loadDataSource==false
                return;
            end
            mws=get_param(obj.DataSourceId,'ModelWorkspace');
            allVars=mws.whos;
            lastIdx=1;
            for idx=1:length(allVars)
                classInfo=meta.class.fromName(allVars(idx).class);
                if~isempty(classInfo)&&(classInfo==baseClassInfo)
                    varIDs(end+1)=...
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
            if obj.loadDataSource==false
                return;
            end
            mws=get_param(obj.DataSourceId,'ModelWorkspace');
            allVars=mws.whos;
            lastIdx=1;
            for idx=1:length(allVars)
                classInfo=meta.class.fromName(allVars(idx).class);
                if~isempty(classInfo)&&(classInfo<=baseClassInfo)
                    varIDs(end+1)=...
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
            if obj.loadDataSource==false
                return;
            end
            mws=get_param(obj.DataSourceId,'ModelWorkspace');
            status=mws.hasVariable(varName);
            if status
                varIDs(1)=Simulink.data.VariableIdentifier(varName,...
                varName,...
                obj.DataSourceId);
            end
        end


        function isVisible=isVariableVisible(obj,varId)
            isVisible=strcmp(varId.DataSourceId,obj.DataSourceId)&&obj.hasVariable(varId.VariableIdWithinSource);
        end


        function value=getVariable(obj,varID)
            assert(strcmp(varID.DataSourceId,obj.DataSourceId))
            if obj.loadDataSource==false
                return;
            end
            mws=get_param(obj.DataSourceId,'ModelWorkspace');
            varName=varID.VariableIdWithinSource;
            value=mws.evalin(varName);
        end


        function[varID,isCreatedInPersistentSource]=createVariable(obj,variableName,value)
            doesNotExists=isempty(obj.identifyByName(variableName));
            assert(doesNotExists,['Variable ',variableName,' exists in the model workspace']);

            mws=get_param(obj.DataSourceId,'ModelWorkspace');
            assignin(mws,variableName,value);
            varID=obj.identifyByName(variableName);
            isCreatedInPersistentSource=false;
        end


        function success=updateVariable(obj,varID,value)
            assert(strcmp(varID.DataSourceId,obj.DataSourceId))
            success=false;
            if obj.loadDataSource==false
                return;
            end
            mws=get_param(obj.DataSourceId,'ModelWorkspace');
            varName=varID.VariableIdWithinSource;
            try
                mws.assignin(varName,value);
                success=true;
            catch
            end
        end


        function success=deleteVariable(obj,varID)
            assert(strcmp(varID.DataSourceId,obj.DataSourceId))
            success=false;
            if obj.loadDataSource==false
                return;
            end
            mws=get_param(obj.DataSourceId,'ModelWorkspace');
            varName=varID.VariableIdWithinSource;
            evalStr=sprintf('clear %s',varName);
            try
                mws.evalin(evalStr);
                success=true;
            catch
            end
        end


        function success=save(obj)
            success=false;
            if obj.loadDataSource==false
                return;
            end
            mws=get_param(obj.DataSourceId,'ModelWorkspace');
            if mws.isdirty
                try

                    if strcmp(mws.DataSource,'MATLAB File')||...
                        strcmp(mws.DataSource,'MAT-File')
                        mws.saveToSource

                    else
                        save_system(obj.DataSourceId);
                    end
                    success=true;
                catch
                end
            else
                success=true;
            end
        end

        function success=revert(obj)
            success=false;
            if obj.loadDataSource==false
                return;
            end
            mws=get_param(obj.DataSourceId,'ModelWorkspace');
            if mws.isdirty
                try

                    if strcmp(mws.DataSource,'MATLAB File')||...
                        strcmp(mws.DataSource,'MAT-File')
                        mws.reload;
                        success=true;
                    else


                        disp('Model Workspace revert is not support if the data source is model');
                    end
                catch
                end
            end
        end


        function showVariableInUI(obj,varId)
            assert(strcmp(varId.DataSourceId,obj.DataSourceId))

            dataObj=obj.getVariable(varId);
            if isobject(dataObj)||isa(dataObj,'handle')||isa(dataObj,'handle.handle')
                DAStudio.Dialog(dataObj,varId.Name,'DLG_STANDALONE');
            else
                slprivate('showWorkspaceVar','model',varId.Name,obj.DataSourceId);
            end
        end


        function openBusEditor(~)
            assert(false,'Bus editor cannot be opened in model workspace');
        end


        function showVariableInModelExplorer(obj,variableId)
            assert(strcmp(variableId.DataSourceId,obj.DataSourceId));


            open_system(obj.DataSourceId);
            slprivate('exploreListNode',obj.DataSourceId,'model',variableId.Name);
        end


        function captureVariableValues(obj,varIds)
            vars=obj.captureVariableValuesInMWS(true,varIds);%#ok<*NASGU>
        end


        function captureVisibleVariableNames(obj)
            varNames=obj.captureVariableNamesInMWS(true);%#ok<*NASGU>
        end


        function restoreCapturedVariableValues(obj)
            vars=obj.captureVariableValuesInMWS(false,[]);
            mws=get_param(obj.DataSourceId,'ModelWorkspace');
            for i=1:numel(vars)
                var=vars(i);
                assignin(mws,var(1).Name,var(1).Value);
            end
        end


        function removeCruft(obj)
            currentVarList={obj.identifyVisibleVariables.Name};
            lastSavedVarList=obj.captureVariableNamesInMWS(false).CapturedVariableNames;
            varsToDelete=setdiff(currentVarList,lastSavedVarList);


            if~isempty(varsToDelete)
                mws=get_param(obj.DataSourceId,'ModelWorkspace');
                mws.evalin(['clear ',strjoin(varsToDelete,' ')]);
            end
        end


        function varExist=hasVariable(obj,varName)
            varExist=false;
            if obj.loadDataSource==false
                return;
            end
            mws=get_param(obj.DataSourceId,'ModelWorkspace');
            varExist=mws.hasVariable(varName);
        end

    end

    methods(Access=private)
        function success=loadDataSource(obj)
            success=false;
            try
                load_system(obj.DataSourceId);


                mws=get_param(obj.DataSourceId,'ModelWorkspace');
                if isempty(mws)
                    success=false;
                else
                    success=true;
                end
            catch
            end
        end

        function varIDs=identifyVariablesByClassName(obj,classType)
            varIDs=Simulink.data.VariableIdentifier.empty(0,0);
            if obj.loadDataSource==false
                return;
            end
            mws=get_param(obj.DataSourceId,'ModelWorkspace');
            allVars=mws.whos;
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


