classdef Concatenate<hdlimplbase.EmlImplBase



    methods
        function this=Concatenate(block)
            supportedBlocks={...
            'built-in/Concatenate',...
            };

            if nargin==0
                block='';
            end

            this.init('SupportedBlocks',supportedBlocks,...
            'Block',block);

        end

    end

    methods
        v_settings=block_validate_settings(~,~)
        hNewC=elaborate(~,hN,hC)
        stateInfo=getStateInfo(~,~)
        v=validateBlock(this,hC)
    end

end

