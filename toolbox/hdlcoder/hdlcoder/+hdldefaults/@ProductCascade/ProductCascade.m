classdef ProductCascade<hdldefaults.CascadeArch



    methods
        function this=ProductCascade(block)
            supportedBlocks={...
            'built-in/Product',...
            };

            if nargin==0
                block='';
            end

            this.init('SupportedBlocks',supportedBlocks,...
            'Block',block,...
            'ArchitectureNames',{'Cascade'},...
            'Deprecates','hdldefaults.ProductCascadeHDLEmission');

        end

    end

    methods
        [outputBlk,outputBlkPosition]=addSLBlockModel(this,hC,originalBlkPath,targetBlkPath)
        v_settings=block_validate_settings(~,~)
        generateSLBlock(this,hC,targetBlkPath)
        latencyInfo=getLatencyInfo(this,hC)
        stateInfo=getStateInfo(this,hC)
        v=validBlockMask(~,slbh)
        v=validateBlock(this,hC)
        vstructs=validateMaskParams(~,hC)
        v=validateProductBlock(~,hC)
    end


    methods(Hidden)
        hNewC=elaborate(this,hN,hC)
        elaborateCascadeProduct(this,hN,hC)
        optimize=optimizeForModelGen(this,hN,hC)
    end

end

