classdef RecipSqrtNewton<hdlimplbase.EmlImplBase



    methods
        function this=RecipSqrtNewton(block)
            supportedBlocks={...
            'built-in/Sqrt',...
            };

            if nargin==0
                block='';
            end

            this.init('SupportedBlocks',supportedBlocks,...
            'Block',block,...
            'ArchitectureNames','RecipSqrtNewton');

        end

    end

    methods
        generateSLBlock(this,hC,targetBlkPath)
        newtonInfo=getBlockInfo(this,slbh)
        latencyInfo=getLatencyInfo(~,hC)
        val=getMaxOversampling(this,hC)
        stateInfo=getStateInfo(this,hC)
        v=validBlockMask(~,slbh)
        v=validateBlock(this,hC)
    end


    methods(Hidden)
        v_settings=block_validate_settings(~,~)
        hNewC=elaborate(this,hN,hC)
        optimize=optimizeForModelGen(this,hN,hC)
        spec=getCharacterizationSpec(~)
        r=isCharacterizableBlock(~)
    end

end

