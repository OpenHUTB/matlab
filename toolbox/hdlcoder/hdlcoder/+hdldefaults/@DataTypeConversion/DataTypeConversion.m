classdef DataTypeConversion<hdlimplbase.EmlImplBase



    methods
        function this=DataTypeConversion(block)
            supportedBlocks={...
            'built-in/DataTypeConversion',...
            };

            if nargin==0
                block='';
            end

            this.init('SupportedBlocks',supportedBlocks,...
            'Block',block,...
            'Deprecates',{'hdldefaults.DataTypeConversionHDLEmission','hdldefaults.DataTypeConversionRTW'});

        end

    end

    methods
        hNewC=elaborate(this,hN,hC)
        stateInfo=getStateInfo(this,hC)
        registerImplParamInfo(this)
        v=validateBlock(~,hC)
    end


    methods(Hidden)
        v_settings=block_validate_settings(this,hC)
        nfpOptions=getNFPImplParamInfo(this,hC)
        spec=getCharacterizationSpec(this)
        r=isCharacterizableBlock(~)
    end

end

