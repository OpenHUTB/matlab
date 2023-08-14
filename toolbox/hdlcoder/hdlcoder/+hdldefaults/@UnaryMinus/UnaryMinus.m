classdef UnaryMinus<hdlimplbase.EmlImplBase



    methods
        function this=UnaryMinus(block)
            supportedBlocks={...
            'built-in/UnaryMinus',...
            };

            if nargin==0
                block='';
            end

            this.init('SupportedBlocks',supportedBlocks,...
            'Block',block,...
            'Deprecates','hdldefaults.UnaryMinusHDLEmission');


        end

    end

    methods
        saturateMode=getBlockInfo(~,hC)
        stateInfo=getStateInfo(this,hC)
        v=validateBlock(~,hC)
    end


    methods(Hidden)
        v_settings=block_validate_settings(~,~)
        hNewC=elaborate(this,hN,hC)
        spec=getCharacterizationSpec(this)
        r=isCharacterizableBlock(~)
    end

end

