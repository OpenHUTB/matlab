classdef ProductTree<hdldefaults.TreeArch



    methods
        function this=ProductTree(block)
            supportedBlocks={...
            'built-in/Product',...
            };

            if nargin==0
                block='';
            end

            this.init('SupportedBlocks',supportedBlocks,...
            'Block',block,...
            'ArchitectureNames',{'Tree'},...
            'Deprecates','hdldefaults.ProductTreeHDLEmission');

        end

    end

    methods
        v_settings=block_validate_settings(this,hC)
        generateSLBlock(this,hC,targetBlkPath)
        [rndMode,satMode,dspMode,nfpOptions]=getBlockInfo(this,hC,slbh)
        stateInfo=getStateInfo(this,hC)
        needDetailedElab=needDetailedElaboration(this,hN,hInSignals,dspMode)
        registerImplParamInfo(this)
        v=validBlockMask(~,slbh)
        v=validateBlock(this,hC)
        vstructs=validateMaskParams(~,hC)
        v=validateProductBlock(~,hC)
    end


    methods(Hidden)
        treeComp=elaborate(this,hN,hC)
        optimize=optimizeForModelGen(this,hN,hC)
        v=validateDSPStyle(this,hC)
    end

end

