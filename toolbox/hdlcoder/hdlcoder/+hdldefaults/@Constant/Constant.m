classdef Constant<hdlimplbase.EmlImplBase



    methods
        function this=Constant(block)
            supportedBlocks={...
            'built-in/Constant',...
            'built-in/Ground',...
            'built-in/StringConstant',...
            'dspobslib/DSP Constant',...
            ['simulink/Sources/Enumerated',newline,'Constant'],...
            };

            if nargin==0
                block='';
            end

            this.init('SupportedBlocks',supportedBlocks,...
            'Block',block,...
            'ArchitectureNames','Constant',...
            'Deprecates','hdldefaults.ConstantHDLEmission');
        end

    end

    methods
        v_settings=block_validate_settings(~,~)
        hNewC=elaborate(this,hN,hC)
        stateInfo=getStateInfo(this,hC)
        tunableParameterInfo=getTunableParameterInfo(this,slHandle)
        msgObj=validateMaskParameterInfo(this,maskParamInfo)
        maskParamInfo=getMaskParameterInfo(this,maskParamInfo)
        val=mustElaborateInPhase1(~,~,~)
        v=validateBlock(~,hC)
    end


    methods(Hidden)
        [cval,vectorParams1D,TunableParamStr,v,isConstBlock]=getBlockDialogValue(this,slbh)
        [cval,vectorParams1D,TunableParamStr,ConstBusName,ConstBusType]=getBlockInfo(this,hC)
        registerImplParamInfo(this)
    end

end

