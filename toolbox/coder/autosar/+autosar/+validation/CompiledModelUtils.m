classdef CompiledModelUtils




    methods(Static,Access=public)

        function cleanupFuncObj=forceCompiledModel(hModel)

            needTerm=false;

            fullname=getfullname(hModel);
            if~autosar.validation.CompiledModelUtils.isCompiled(hModel)
                feval(fullname,[],[],[],'compile');
                needTerm=true;
            end

            cleanupFuncObj=[];
            if needTerm
                cleanupFuncObj=onCleanup(@()feval(getfullname(hModel),[],[],[],'term'));
            end


        end

        function cleanupFuncObj=forceCompiledModelForRTW(hModel)

            needTerm=false;

            fullname=getfullname(hModel);
            if~autosar.validation.CompiledModelUtils.isCompiled(hModel)
                feval(fullname,[],[],[],'compileForRTW');
                needTerm=true;
            end

            cleanupFuncObj=[];
            if needTerm
                cleanupFuncObj=onCleanup(@()feval(getfullname(hModel),[],[],[],'term'));
            end


        end

        function isCompiled=isCompiled(hModel)

            simStatus=get_param(hModel,'SimulationStatus');
            isCompiled=strcmpi(simStatus,'paused')||...
            strcmpi(simStatus,'initializing')||...
            strcmpi(simStatus,'running')||...
            strcmpi(simStatus,'updating');

        end

        function wsVar=getReferencedWSVars(hModel,ensureModelCompiled)

            if nargin<2
                ensureModelCompiled=true;
            end

            if ensureModelCompiled
                assert(~strcmp(get_param(hModel,'SimulationStatus'),'stopped'),...
                'The model must be compiled');
            end

            mode='cached';


            modelName=get_param(hModel,'Name');
            vars=Simulink.findVars(modelName,'SearchMethod',mode);
            wsVar=[];
            for i=1:length(vars)
                if strcmpi(vars(i).SourceType,'data dictionary')||...
                    strcmpi(vars(i).SourceType,'base workspace')
                    wsVar(end+1).objName=vars(i).Name;%#ok
                    wsVar(end).obj=Simulink.data.internal.getModelGlobalVariable(...
                    modelName,vars(i).Name);
                end
            end
        end
    end


end


