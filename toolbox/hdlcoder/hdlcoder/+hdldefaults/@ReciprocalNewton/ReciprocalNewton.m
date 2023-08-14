classdef ReciprocalNewton<hdlimplbase.EmlImplBase





    methods
        function this=ReciprocalNewton(block)
            supportedBlocks={...
            'built-in/Math',...
            'built-in/Reciprocal',...
            };

            if nargin==0
                block='';
            end

            this.init('SupportedBlocks',supportedBlocks,...
            'Block',block,...
            'ArchitectureNames','ReciprocalNewton',...
            'Deprecates','hdldefaults.RecipNewtonHDLEmission');

        end

    end

    methods
        hNewC=elaborate(this,hN,hC)
        generateSLBlock(this,hC,targetBlkPath)
        newtonInfo=getBlockInfo(this,hC)
        val=getMaxOversampling(this,hC)
        stateInfo=getStateInfo(this,hC)
        v=validateBlock(~,hC)
        v=getHelpInfo(this,blkTag)
    end


    methods(Hidden)
        v_settings=block_validate_settings(~,~)
        latencyInfo=getLatencyInfo(this,hC)
        optimize=optimizeForModelGen(this,hN,hC)
        spec=getCharacterizationSpec(this)
        r=isCharacterizableBlock(~)
        v=validBlockMask(~,slbh)
    end

end

