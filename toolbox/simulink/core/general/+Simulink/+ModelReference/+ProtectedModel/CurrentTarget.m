




classdef CurrentTarget
    properties(Transient,Access=private)
        fModelToCurrentTargetMap;
    end

    methods(Access=private)
        function obj=CurrentTarget()
            obj.fModelToCurrentTargetMap=containers.Map;
        end
    end

    methods(Static,Access=private)
        function out=getCurrentTargetObj()
            persistent currentTarget;
            if isempty(currentTarget)
                currentTarget=Simulink.ModelReference.ProtectedModel.CurrentTarget();
            end
            out=currentTarget;
        end
    end

    methods(Static,Hidden)
        function out=get(modelName)
            import Simulink.ModelReference.ProtectedModel.*;

            tgtObj=CurrentTarget.getCurrentTargetObj();
            if isKey(tgtObj.fModelToCurrentTargetMap,modelName)
                out=tgtObj.fModelToCurrentTargetMap(modelName);
            else
                opts=Simulink.ModelReference.ProtectedModel.getOptions(modelName,'runConsistencyChecksNoPlatform');
                tgtObj.fModelToCurrentTargetMap(modelName)=opts.defaultTarget;
                out=opts.defaultTarget;
            end
        end

        function set(modelName,target)



            tgtObj=Simulink.ModelReference.ProtectedModel.CurrentTarget.getCurrentTargetObj();
            tgtObj.fModelToCurrentTargetMap(modelName)=target;
        end

        function clear(modelName)


            tgtObj=Simulink.ModelReference.ProtectedModel.CurrentTarget.getCurrentTargetObj();
            if isKey(tgtObj.fModelToCurrentTargetMap,modelName)
                tgtObj.fModelToCurrentTargetMap.remove(modelName);
            end
        end
    end
end