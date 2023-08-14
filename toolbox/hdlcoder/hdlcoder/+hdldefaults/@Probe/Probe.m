classdef Probe<hdlimplbase.EmlImplBase


    methods
        function this=Probe(block)
            supportedBlocks={...
'built-in/Probe'...
            };

            if nargin==0
                block='';
            end

            this.init('SupportedBlocks',supportedBlocks,...
            'Block',block);
        end
    end

    methods
        stateInfo=getStateInfo(~,~)
    end

    methods(Hidden)
        [sigWidth,sigST,sigComplexity,sigDimensions]=getBlockInfo(~,hC)
        v_settings=block_validate_settings(~,~)
        hNewC=elaborate(this,hN,hC)
        v=validateBlock(~,~)
        registerImplParamInfo(this)
    end
end
