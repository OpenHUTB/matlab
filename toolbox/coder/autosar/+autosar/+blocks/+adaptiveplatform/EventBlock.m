classdef EventBlock<handle





    methods(Static,Access=public)

        function tf=isEventSendBlock(blk)
            libData=libinfo(blk);
            tf=length(libData)==1&&...
            strcmp(libData.ReferenceBlock,'autosarlibaprouting/Event Send');
        end

        function tf=isEventReceiveBlock(blk)
            libData=libinfo(blk);
            tf=length(libData)==1&&...
            strcmp(libData.ReferenceBlock,'autosarlibaprouting/Event Receive');
        end

        function tf=isEventSendOrReceiveBlock(blk)
            tf=autosar.blocks.adaptiveplatform.EventBlock.isEventSendBlock(blk)||...
            autosar.blocks.adaptiveplatform.EventBlock.isEventReceiveBlock(blk);
        end

        function updateBlock(blkPath)
            try



                if autosar.validation.CompiledModelUtils.isCompiled(bdroot(blkPath))
                    autosar.api.Utils.autosarlicensed(true);
                end
            catch ME

                autosar.mm.util.MessageReporter.throwException(ME);
            end
        end
    end

end


