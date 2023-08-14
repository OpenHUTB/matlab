classdef DotProduct<hdlimplbase.EmlImplBase



    methods
        function this=DotProduct(block)
            supportedBlocks={...
            'built-in/DotProduct',...
            };

            if nargin==0
                block='';
            end

            this.init('SupportedBlocks',supportedBlocks,...
            'Block',block,...
            'ArchitectureNames','Linear');
        end

    end

    methods
        dotpComp=elaborate(this,hN,hC)
        stateInfo=getStateInfo(this,hC)
        registerImplParamInfo(this)
        v=validateBlock(this,hC)
    end


    methods(Hidden)
        v_settings=block_validate_settings(this,hC)
        blockInfo=getBlockInfo(this,hC)
        postElab(this,hN,hPreElabC,hPostElabC)
    end

end

