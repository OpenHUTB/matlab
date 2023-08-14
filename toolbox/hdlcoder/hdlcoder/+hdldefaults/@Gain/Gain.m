classdef Gain<hdlimplbase.EmlImplBase



    methods
        function this=Gain(block)
            supportedBlocks='built-in/Gain';

            if nargin==0
                block='';
            end

            this.init('SupportedBlocks',supportedBlocks,...
            'Block',block,...
            'ArchitectureNames','Product',...
            'Deprecates','hdldefaults.GainMultHDLEmission','hdldefaults.GainCSDHDLEmission','hdldefaults.GainFCSDHDLEmission');

        end

    end

    methods
        v_settings=block_validate_settings(~,~)
        hNewC=elaborate(this,hN,hC)
        stateInfo=getStateInfo(this,hC)
        matMulStrategy=getMatMulStrategy(this,hC)
        tunableParameterInfo=getTunableParameterInfo(this,slHandle)
        msgObj=validateMaskParameterInfo(this,maskParamInfo)
        maskParamInfo=getMaskParameterInfo(this,maskParamInfo)
        compatible=isAdaptivePipeliningCompatible(this,hC)
        val=mustElaborateInPhase1(~,~,~)
        registerImplParamInfo(this)
        v=validBlockMask(~,slbh)
        v=validateBlock(this,hC)
        v=validateDSPStyle(this,hC)
        v=validateImplParams(this,hC)
    end


    methods(Hidden)
        hNewC=elaborateMain(this,hN,hC,constMultiplierOptimMode,gainFactor,gainMode,rndMode,satMode,dspMode,nfpOptions)
        [cval,nfpOptions,TunableParamStr,TunableParamType]=getBlockDialogValue(this,slbh)
        spec=getCharacterizationSpec(this)
        r=isCharacterizableBlock(~)
    end

end

