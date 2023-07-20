classdef M3IGarbageCollectorModelContext<autosar.mm.sl2mm.internal.M3IGarbageCollectorContext






    properties(Access=private)
        ModelName;
        RestoreDirtyState;
    end

    methods
        function this=M3IGarbageCollectorModelContext(modelName)
            this.ModelName=bdroot(modelName);
        end

        function m3iModel=getM3IModel(this)
            m3iModel=autosar.api.Utils.m3iModel(this.ModelName);
        end

        function cacheRestoreDirtyState(this)

            modelName=this.ModelName;
            previousDirtyState=get_param(modelName,'Dirty');
            this.RestoreDirtyState=onCleanup(@()set_param(modelName,'Dirty',previousDirtyState));
        end
    end
end


