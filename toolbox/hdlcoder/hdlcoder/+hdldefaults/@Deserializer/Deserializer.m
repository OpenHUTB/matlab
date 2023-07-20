classdef Deserializer<hdlimplbase.EmlImplBase



    methods
        function this=Deserializer(block)
            supportedBlocks={...
            'hdlstreaminglib/Deserializer',...
            'hdlstreaminglib/Deserializer_Base',...
            'hdlstreaminglib/Deserializer2',...
            'hdlstreaminglib/Deserializer2_Base',...
            'hdlstreaminglib/Deserializer_dsp',...
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
    end

end

