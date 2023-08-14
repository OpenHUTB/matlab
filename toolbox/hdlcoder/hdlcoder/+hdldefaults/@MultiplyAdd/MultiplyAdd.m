classdef MultiplyAdd<hdlimplbase.EmlImplBase



    methods
        function this=MultiplyAdd(block)
            supportedBlocks={...
'hdlsllib/HDL Operations/Multiply-Add'...
            };

            if nargin==0
                block='';
            end

            this.init('SupportedBlocks',supportedBlocks,...
            'Block',block);


        end

    end

    methods
        stateInfo=getStateInfo(this,hC)
        compatible=isAdaptivePipeliningCompatible(this,hC)
        registerImplParamInfo(this)
    end


    methods(Hidden)
        v_settings=block_validate_settings(~,~)
        hNewC=elaborate(this,hN,hC)
        [rndMode,ovMode,hwModeLatency,signs,nfpOptions,fused]=getBlockInfo(this,slbh,hC)
        latencyInfo=getHwModeLatency(this,hC)
        ret=getPotentiallyInsertsPipelines(this,hC)
        v=validateBlock(this,hC)
        v=validatePipelineDepth(this,hC)
    end

end

