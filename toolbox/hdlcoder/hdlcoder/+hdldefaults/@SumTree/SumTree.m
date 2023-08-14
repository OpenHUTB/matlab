classdef SumTree<hdldefaults.TreeArch



    methods
        function this=SumTree(block)
            supportedBlocks={...
            'built-in/Sum',...
            };

            if nargin==0
                block='';
            end

            this.init('SupportedBlocks',supportedBlocks,...
            'Block',block,...
            'ArchitectureNames',{'Tree'},...
            'Deprecates','hdldefaults.SumTreeHDLEmission');

        end

    end

    methods
        v_settings=block_validate_settings(this,hC)
        generateSLBlock(this,hC,targetBlkPath)
        stateInfo=getStateInfo(this,hC)
        needDetailedElab=needDetailedElaboration(this,hN,hInSignals,dspMode)
        registerImplParamInfo(this)
        v=validBlockMask(~,slbh)
    end


    methods(Hidden)
        treeComp=elaborate(this,hN,hC)
        optimize=optimizeForModelGen(this,hN,hC)
        v=validateBlock(this,hC)
        vstructs=validateMaskParams(~,hC)
        v=validatePortDatatypes(this,hC)
    end

end

