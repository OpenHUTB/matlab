classdef Product<hdlimplbase.EmlImplBase



    methods
        function this=Product(block)
            supportedBlocks={...
            'built-in/Product',...
            };

            if nargin==0
                block='';
            end

            this.init('SupportedBlocks',supportedBlocks,...
            'Block',block,...
            'ArchitectureNames','Linear',...
            'Deprecates',{'hdldefaults.ProductLinearHDLEmission','hdldefaults.ProductRTW'});
        end
    end

    methods
        v_settings=block_validate_settings(~,~)
        mulComp=elaborate(this,hN,hC)
        implInfo=truncateImplParams(~,slbh,implInfo)
        matrixMul=getMatMulKind(~)
        stateInfo=getStateInfo(this,hC)
        compatible=isAdaptivePipeliningCompatible(this,hC)
        registerImplParamInfo(this)
        v=validBlockMask(~,slbh)
        v=validateBlock(this,hC)
        v=validateImplParams(this,hC)
        v=validatePortDatatypes(this,hC)
    end

    methods(Hidden)
        retval=allowElabModelGen(this,hN,hC)
        [rndMode,ovMode,inputSigns,dspMode,nfpOptions,blockOptions,isPOE]=getBlockInfo(this,hC)
        nfpOptions=getNFPImplParamInfo(this,hC,inputSigns)
        v=validateDSPStyle(this,hC)
        spec=getCharacterizationSpec(~)
        r=isCharacterizableBlock(~)
    end
end
