classdef Sum<hdlimplbase.EmlImplBase



    methods
        function this=Sum(block)
            supportedBlocks={...
            'built-in/Sum',...
            };

            if nargin==0
                block='';
            end

            this.init('SupportedBlocks',supportedBlocks,...
            'Block',block,...
            'ArchitectureNames','Linear',...
            'Deprecates',{'hdldefaults.SumLinearHDLEmission','hdldefaults.SumRTW'});
        end
    end

    methods
        v_settings=block_validate_settings(~,~)
        addComp=elaborate(this,hN,hC)
        generateSLBlock(this,hC,targetBlkPath)
        stateInfo=getStateInfo(this,hC)
        optimize=optimizeForModelGen(this,~,hC)
        registerImplParamInfo(this)
        v=validateBlock(~,hC)
    end

    methods(Hidden)
        retval=allowElabModelGen(this,hN,hC)
        [rndMode,ovMode,accType,inputsigns]=getBlockInfo(this,hC)
        inputsigns=getInputSigns(this,slbh)
        nfpOptions=getNFPImplParamInfo(this,hC)
        spec=getCharacterizationSpec(this)
        r=isCharacterizableBlock(~)
    end
end
