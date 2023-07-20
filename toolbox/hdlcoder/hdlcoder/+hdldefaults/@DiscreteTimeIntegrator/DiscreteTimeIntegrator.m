classdef DiscreteTimeIntegrator<hdlimplbase.EmlImplBase



    methods
        function this=DiscreteTimeIntegrator(block)
            supportedBlocks={...
            'built-in/DiscreteIntegrator',...
            };

            if nargin==0
                block='';
            end

            this.init('SupportedBlocks',supportedBlocks,...
            'Block',block,...
            'Deprecates',{'hdldefaults.DiscreteTimeIntegratorRTW'});

        end

    end

    methods
        v_settings=block_validate_settings(~,hC)
        hNewC=elaborate(this,hN,hC)
        [dtiInfo,nfpOptions]=getBlockInfo(this,slbh)
        latencyInfo=getLatencyInfo(~,hC)
        stateInfo=getStateInfo(this,hC)
        val=hasDesignDelay(~,~,~)
        optimize=optimizeForModelGen(~,~,hC)
        registerImplParamInfo(this)
        v=validateBlock(~,hC)
    end


    methods(Hidden)
        retval=allowElabModelGen(this,hN,hC)
        v=validatePortDatatypes(this,hC)
    end

end

