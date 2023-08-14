classdef Merge<hdlimplbase.EmlImplBase





    methods
        function this=Merge(block)
            supportedBlocks={...
            'built-in/Merge',...
            };

            if nargin==0
                block='';
            end

            this.init('SupportedBlocks',supportedBlocks,...
            'Block',block);
        end
    end

    methods(Hidden)
        hNewC=elaborate(this,hN,hC)
        v=validateBlock(this,hC)
        v_settings=block_validate_settings(~,~)
        val=mustElaborateInPhase1(~,~,~)
        actionSignal=findActionSignalInNtwk(~,mergeInput)
    end

    methods(Hidden,Static)
        [returnSig,nicArray]=findSignalThroughHierarchy(inSig,predicate,nicArray)
        actionSignal=actionSignalPred(inSig)
        returnSig=signalInNtwkPred(signal,targetNtwk)
    end

end
