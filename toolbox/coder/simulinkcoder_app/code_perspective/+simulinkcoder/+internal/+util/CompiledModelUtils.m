classdef CompiledModelUtils




    methods(Static,Access=public)
        function cleanupFuncObj=forceCompiledModel(hModel)
            needTerm=false;
            fullname=getfullname(hModel);
            if~simulinkcoder.internal.util.CompiledModelUtils.isCompiled(hModel)
                try
                    feval(fullname,[],[],[],'compile');
                    needTerm=true;
                catch me
                    rethrow(me);
                end
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
    end
end


