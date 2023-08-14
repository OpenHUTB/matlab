

classdef FunctionCallerBlock<slci.simulink.Block
    properties(Access=private)
        targetFunctionHandle=[];
        fisFcnBlkHdlComputed=false;
    end
    methods


        function obj=FunctionCallerBlock(aBlk,aModel)
            obj=obj@slci.simulink.Block(aBlk,aModel);
            obj.setSupportsBuses(true);
            obj.setSupportsEnums(true);

            obj.addConstraint(...
            slci.compatibility.FunctionCallerTargetConstraint);
        end


        function out=getFunctionHandle(aObj)
            out=[];
            if~aObj.fisFcnBlkHdlComputed
                aObj.findTargetFuncHandle;
            end
            if~isempty(aObj.targetFunctionHandle)
                out=aObj.targetFunctionHandle;
            end
        end
    end


    methods(Access=private)


        function findTargetFuncHandle(aObj)
            assert(~aObj.fisFcnBlkHdlComputed)
            mdl=aObj.ParentModel;
            funcInfos=mdl.getFuncInfoForCaller(aObj.getHandle);
            if~isempty(funcInfos)
                assert(numel(funcInfos)==1,...
                'Function Caller block can only call 1 function');
                aObj.targetFunctionHandle=funcInfos{1}.getSrcBlkHandle;
            end
            aObj.fisFcnBlkHdlComputed=true;
        end
    end
end
