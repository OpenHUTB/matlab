classdef Abs<hdlimplbase.EmlImplBase



    methods
        function this=Abs(block)
            supportedBlocks={...
'built-in/Abs'...
            };

            if nargin==0
                block='';
            end

            this.init('SupportedBlocks',supportedBlocks,...
            'Block',block,...
            'Deprecates','hdldefaults.AbsHDLEmission');
        end

    end

    methods
        [roundingMode,saturateMode,nfpOptions,isComplex]=getBlockInfo(this,hC)
        stateInfo=getStateInfo(this,hC)
        registerImplParamInfo(this)
    end


    methods(Hidden)
        v_settings=block_validate_settings(~,~)
        hNewC=elaborate(this,hN,hC)
        v=validateBlock(this,hC)
        spec=getCharacterizationSpec(this)
        r=isCharacterizableBlock(~)
    end

end
