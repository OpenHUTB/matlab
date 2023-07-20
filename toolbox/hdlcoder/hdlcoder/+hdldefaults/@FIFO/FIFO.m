classdef FIFO<hdlimplbase.EmlImplBase




    methods
        function this=FIFO(block)
            supportedBlocks={'hdlsllib/HDL RAMs/HDL FIFO'};

            if nargin==0
                block='';
            end

            this.init('SupportedBlocks',supportedBlocks,...
            'Block',block,...
            'ArchitectureNames','FIFO');

        end

    end

    methods
        info=getBlockInfo(this,slbh)
        val=getMaxOversampling(this,hC)
        stateInfo=getStateInfo(this,hC)
        val=hasDesignDelay(~,~,~)
        registerImplParamInfo(this)
    end


    methods(Hidden)
        v_settings=block_validate_settings(~,~)
        hNewC=elaborate(this,hN,hC)
        v=validateBlock(~,~)
        v=validatePortDatatypes(~,hC)
    end

end

