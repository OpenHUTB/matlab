classdef ReciprocalRsqrtBasedNewton<hdlimplbase.EmlImplBase



    methods
        function this=ReciprocalRsqrtBasedNewton(block)
            supportedBlocks={...
            'built-in/Math',...
'built-in/Product'...
            };

            if nargin==0
                block='';
            end

            this.init('SupportedBlocks',supportedBlocks,...
            'Block',block,...
            'ArchitectureNames','ReciprocalRsqrtBasedNewton',...
            'DeprecatedArchName','RecipNewton',...
            'Deprecates','hdldefaults.RecipNewton');

        end

    end

    methods
        hNewC=elaborate(this,hN,hC)
        generateSLBlock(this,hC,targetBlkPath)
        newtonInfo=getBlockInfo(this,slbh)
        choice=getChoice(this)
        val=getMaxOversampling(this,hC)
        stateInfo=getStateInfo(this,hC)
        registerImplParamInfo(this)
        v=validBlockMask(~,slbh)
        v=validateBlock(~,hC)
        v=validateImplParams(this,hC)
    end


    methods(Hidden)
        v_settings=block_validate_settings(~,~)
        latencyInfo=getLatencyInfo(this,hC)
        optimize=optimizeForModelGen(this,hN,hC)
        spec=getCharacterizationSpec(this)
        r=isCharacterizableBlock(~)
    end

end

