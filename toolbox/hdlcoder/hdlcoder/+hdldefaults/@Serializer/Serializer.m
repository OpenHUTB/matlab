classdef Serializer<hdlimplbase.EmlImplBase



    methods
        function this=Serializer(block)
            supportedBlocks={...
            'hdlstreaminglib/Serializer',...
            'hdlstreaminglib/Serializer_Base',...
            'hdlstreaminglib/Serializer2',...
            'hdlstreaminglib/Serializer_dsp',...
            'hdlstreaminglib/Serializer2_dsp',...
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
        val=getMaxOversampling(this,hC)
        stateInfo=getStateInfo(this,hC)
        val=hasDesignDelay(~,~,~)
    end


    methods(Hidden)
        v_settings=block_validate_settings(~,~)
        hNewC=elaborate(this,hN,hC)
    end

end

