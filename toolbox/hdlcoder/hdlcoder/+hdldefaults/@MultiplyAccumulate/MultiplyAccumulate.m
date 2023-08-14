classdef MultiplyAccumulate<hdlimplbase.EmlImplBase



    methods
        function this=MultiplyAccumulate(block)
            supportedBlocks={...
'hdlsllib/HDL Operations/Multiply-Accumulate'...
            };

            if nargin==0
                block='';
            end

            this.init('SupportedBlocks',supportedBlocks,...
            'ArchitectureNames','Auto',...
            'Block',block);


        end

    end

    methods
        latencyInfo=getLatencyInfo(this,hC)
        stateInfo=getStateInfo(this,hC)
        val=hasDesignDelay(this,hN,hC)
    end


    methods(Hidden)
        v_settings=block_validate_settings(~,~)
        hNewC=elaborate(this,hN,hC)
        ret=getPotentiallyInsertsPipelines(this,hC)
        v=validateBlock(this,hC)
    end


    methods(Static)
        em=getElabMode(~)
    end

end

