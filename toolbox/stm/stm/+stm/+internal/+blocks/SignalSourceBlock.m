classdef SignalSourceBlock<handle

    properties
handle
    end

    methods
        handle=getHandle(obj)
        sig=getSignalFromComponent(obj,componentName,inputSignalFile);
        [handle,ind]=setActiveComponent(obj,name);
        tMax=getMaxTime(obj,componentName);
        delete(obj,ind);
        componentNames=getComponentNames(obj);
        type=getSignalBlockType(obj);
    end

    methods(Static)
        function block=getBlock(model,overrideScenario)

            if nargin<=1
                overrideScenario='';
            end

            block=stm.internal.blocks.SignalEditorBlock(model,overrideScenario);


            if~isempty(block.handle)
                overrideScenario=block.overrideScenario;

                signalBuilderBlock=stm.internal.blocks.SignalBuilderBlock(model,overrideScenario);
                if~isempty(signalBuilderBlock.getHandle())
                    stm.internal.MRT.share.error('stm:general:TooManyInputSourceBlocks',model);
                end


                block.setData(overrideScenario);
            else
                block=stm.internal.blocks.SignalBuilderBlock(model,overrideScenario);
            end
        end
    end
end
