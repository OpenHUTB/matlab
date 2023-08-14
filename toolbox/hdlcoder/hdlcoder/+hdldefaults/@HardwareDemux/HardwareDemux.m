classdef HardwareDemux<hdlimplbase.EmlImplBase



    methods
        function this=HardwareDemux(block)
            supportedBlocks={...
'hdlstreaminglib/Hardware Demux'...
            };

            if nargin==0
                block='';
            end




            this.setPublish(false);


            this.init('SupportedBlocks',supportedBlocks,...
            'Block',block);


        end

    end

    methods
        stateInfo=getStateInfo(this,hC)
        val=hasDesignDelay(~,~,~)
    end


    methods(Hidden)
        v_settings=block_validate_settings(~,~)
        hNewC=elaborate(this,hN,hC)
        v=validateBlock(~,hC)
    end

end

