classdef BitConcat<hdlimplbase.EmlImplBase



    methods
        function this=BitConcat(block)
            supportedBlocks={...
            'built-in/BitConcat',...
            'hdlsllib/Logic and Bit Operations/Bit Concat',...
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
    end

    methods(Hidden)
        hNewC=elaborate(this,hN,hC)
        spec=getCharacterizationSpec(~)
        r=isCharacterizableBlock(~)
        v_settings=block_validate_settings(this,hC)
        v=validateBlock(this,hC)
    end

end