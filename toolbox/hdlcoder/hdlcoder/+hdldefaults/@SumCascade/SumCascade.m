classdef SumCascade<hdldefaults.CascadeArch



    methods
        function this=SumCascade(block)
            supportedBlocks={...
            'built-in/Sum',...
            };

            if nargin==0
                block='';
            end

            this.init('SupportedBlocks',supportedBlocks,...
            'Block',block,...
            'ArchitectureNames',{'Cascade'},...
            'Deprecates','hdldefaults.SumCascadeHDLEmission');

        end

    end

    methods
        v_settings=block_validate_settings(~,~)
        accumType=getAccumTypeForSum(this,slbh,hOutType)
        [compType,accumType,rndMode,satMode]=getBlockInfo(this,slbh,hOutType)
        latencyInfo=getLatencyInfo(this,hC)
        stateInfo=getStateInfo(this,hC)
        v=validBlockMask(~,slbh)
        v=validateBlock(this,hC)
        vstructs=validateMaskParams(~,hC)
    end


    methods(Hidden)
        [outputBlk,outputBlkPosition]=addSLBlockModel(this,hC,originalBlkPath,targetBlkPath)
        hNewC=elaborate(this,hN,hC)
        elaborateCascadeSum(this,hN,hC)
        generateSLBlock(this,hC,targetBlkPath)
        optimize=optimizeForModelGen(this,hN,hC)
        v=validatePortDatatypes(this,hC)
    end

end

