classdef DotProductTree<hdldefaults.TreeArch



    methods
        function this=DotProductTree(block)
            supportedBlocks={...
            'built-in/DotProduct',...
            };

            if nargin==0
                block='';
            end

            this.init('SupportedBlocks',supportedBlocks,...
            'Block',block,...
            'ArchitectureNames','Tree');
        end

    end

    methods
        dotpComp=elaborate(this,hN,hC)
        stateInfo=getStateInfo(this,hC)
        flag=isInputOrientationMixed(this,hInSignals)
        registerImplParamInfo(this)
        v=validateBlock(this,hC)
    end


    methods(Hidden)
        v_settings=block_validate_settings(this,hC)
        blockInfo=getBlockInfo(this,hC)
        postElab(this,hN,hPreElabC,hPostElabC)
    end

end

