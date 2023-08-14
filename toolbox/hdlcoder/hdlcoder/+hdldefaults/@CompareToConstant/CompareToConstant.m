classdef CompareToConstant<hdlimplbase.EmlImplBase



    methods
        function this=CompareToConstant(block)
            supportedBlocks={...
            'simulink/Logic and Bit Operations/Compare To Constant',...
            };

            if nargin==0
                block='';
            end

            this.init('SupportedBlocks',supportedBlocks,...
            'Block',block,...
            'Deprecates','hdldefaults.CompareToConstHDLEmission');

        end

    end

    methods
        hNewC=elaborate(~,hN,hC)
        stateInfo=getStateInfo(this,hC)
        v=validateBlock(~,hC)
        [cval,relopval]=getBlockDialogValue(this,slbh)
        msgObj=validateMaskParameterInfo(this,maskParamInfo)
        maskParamInfo=getMaskParameterInfo(this,maskParamInfo)
    end


    methods(Hidden)
        v_settings=block_validate_settings(~,~)
        v=validatePortDatatypes(this,hC)

    end

end

