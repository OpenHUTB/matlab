classdef ForIterator<hdlimplbase.EmlImplBase



    methods
        function this=ForIterator(block)
            supportedBlocks={...
            'built-in/ForIterator',...
            };

            if nargin==0
                block='';
            end

            this.init('SupportedBlocks',supportedBlocks,...
            'Block',block);
        end
    end

    methods
        stateInfo=getStateInfo(this,hC)
        val=hasDesignDelay(~,~,~)
    end


    methods(Hidden)
        v_settings=block_validate_settings(this,hC)
        hNewC=elaborate(this,hN,hC)
        v=validateBlock(~,hC)
    end

end

