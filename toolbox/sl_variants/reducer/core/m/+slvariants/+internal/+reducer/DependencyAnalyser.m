classdef(Sealed,Hidden)DependencyAnalyser<handle




    methods(Access=public)

        function obj=DependencyAnalyser(modelPath)
            obj.ModelPath=modelPath;
            [~,obj.ModelName,~]=fileparts(modelPath);
        end

        function[varDeps,success]=getVariableDependenciesForReducedModel(obj,useCached)
            [varDeps,success]=obj.getVariableDependenciesImpl(obj.ModelName,useCached);

            if~success
                obj.createMExceptionForFindVarsFailures();
            end
        end

        function[varDeps,success]=getVariableDependenciesForBlock(obj,blk,useCached)
            [varDeps,success]=obj.getVariableDependenciesImpl(blk,useCached);


        end

        function[fileDeps,success]=getFileDependencies(obj)
            success=true;
            fileDeps={};
            try
                depGraph=dependencies.internal.analyze(obj.ModelPath);
                fileDeps=depGraph.Nodes.Name(depGraph.Nodes.Resolved);
                missingDeps=depGraph.Nodes.Name(~depGraph.Nodes.Resolved);
                obj.createMExceptionForMissingFileDeps(missingDeps,depGraph);
            catch ex
                obj.DepAnalysisError=ex;
                success=false;
                obj.createMExceptionForDepAnalysisFailures();
            end
        end

        function failures=getMissingDependenciesFailures(obj)
            failures=obj.MissingFileDepFailures;
        end

        function failures=getVariableDependenciesFailures(obj)
            failures=obj.FindVarsFailures;
        end

        function failures=getFileDependenciesFailures(obj)
            failures=obj.DepAnalysisFailures;
        end

    end

    methods(Access=private)

        function addWarningForMissingFileDeps(obj,missingDeps)
            if isempty(missingDeps)
                return;
            end



            missingDepsStr=strjoin(missingDeps,',');
            warnid='Simulink:Variants:MissingFileDeps';
            warnmsg=message(warnid,obj.ModelName,missingDepsStr);
            obj.MissingFileDepFailures(end+1)=MException(warnmsg);
        end

        function addWarningForSrcFilesInMissingFileDeps(obj,missingDeps,depGraph)
            if isempty(missingDeps)
                return;
            end




            for idx=1:numel(missingDeps)
                missingDepFilesCell=predecessors(depGraph,missingDeps{idx});
                missingDepFileString='';


                for idxFiles=1:numel(missingDepFilesCell)
                    filePath=missingDepFilesCell{idxFiles};
                    missingDepFileString=sprintf(['%s',newline,'%s'],missingDepFileString,filePath);
                end

                warnid='Simulink:Variants:VariantReducerMissingDepFiles';
                warnmsg=message(warnid,missingDeps{idx},missingDepFileString);
                obj.MissingFileDepFailures(end+1)=MException(warnmsg);
            end
        end

        function createMExceptionForMissingFileDeps(obj,missingDeps,depGraph)
            if isempty(missingDeps)
                return;
            end
            obj.addWarningForMissingFileDeps(missingDeps);
            obj.addWarningForSrcFilesInMissingFileDeps(missingDeps,depGraph);
        end

        function createMExceptionForFindVarsFailures(obj)%#ok<*MANU>
            if isempty(obj.FindVarsError)
                return;
            end

            [excepIds,excepMsgs]=slprivate('getAllErrorIdsAndMsgs',obj.FindVarsError);
            for idx=1:numel(excepIds)
                obj.FindVarsFailures(end+1)=MException(excepIds{idx},excepMsgs{idx});
            end
        end

        function createMExceptionForDepAnalysisFailures(obj)%#ok<*MANU>
            if isempty(obj.DepAnalysisError)
                return;
            end

            [excepIds,excepMsgs]=slprivate('getAllErrorIdsAndMsgs',obj.DepAnalysisError);
            for idx=1:numel(excepIds)
                obj.DepAnalysisFailures(end+1)=MException(excepIds{idx},excepMsgs{idx});
            end
        end

        function[varDeps,success]=getVariableDependenciesImpl(obj,context,useCached)
            if useCached
                [varDeps,success]=obj.callFindVars(context,'cached');

                if~success
                    [varDeps,success]=obj.callFindVars(context,'compiled');
                end
            else
                [varDeps,success]=obj.callFindVars(context,'compiled');
            end
        end

        function[varDeps,success]=callFindVars(obj,context,searchMethod)
            success=true;
            varDeps={};
            try
                varDeps=Simulink.findVars(context,'SearchReferencedModels','on','SearchMethod',searchMethod);
            catch ex
                obj.FindVarsError=ex;
                success=false;
            end
        end

    end

    properties(Access=private)

        FindVarsError MException;

        DepAnalysisError MException;

        ModelPath(1,:)char;

        ModelName(1,:)char;

        FindVarsFailures(1,:)MException;

        DepAnalysisFailures(1,:)MException;

        MissingFileDepFailures(1,:)MException;

    end

end
