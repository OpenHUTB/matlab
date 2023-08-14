classdef ReciprocalNewtonSingleRate<hdlimplbase.EmlImplBase





    methods
        function this=ReciprocalNewtonSingleRate(block)
            supportedBlocks={...
            'built-in/Math',...
            'built-in/Reciprocal',...
'hdlNFPMathLib/NFPNewtonReciprocal'
            };

            if nargin==0
                block='';
            end

            this.init('SupportedBlocks',supportedBlocks,...
            'Block',block,...
            'ArchitectureNames','ReciprocalNewtonSingleRate',...
            'Deprecates','hdldefaults.RecipNewtonHDLEmission');

        end

    end

    methods
        hNewC=elaborate(this,hN,hC)
        generateSLBlock(this,hC,targetBlkPath)
        newtonInfo=getBlockInfo(this,hC)
        stateInfo=getStateInfo(this,hC)
        registerImplParamInfo(this)
        v=validateBlock(~,hC)
        v=getHelpInfo(this,blkTag)
    end


    methods(Hidden)
        v_settings=block_validate_settings(~,~)
        latencyInfo=getLatencyInfo(this,hC)
        optimize=optimizeForModelGen(this,hN,hC)
        v=validBlockMask(~,slbh)
    end

end

