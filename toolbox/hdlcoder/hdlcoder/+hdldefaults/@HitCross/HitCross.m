classdef HitCross<hdlimplbase.EmlImplBase



    methods
        function this=HitCross(block)
            supportedBlocks={...
            'built-in/HitCross',...
            };

            if nargin==0
                block='';
            end

            desc=struct('ShortListing','Generate HDL Code for HitCross Block',...
            'HelpText','HDL will be emitted for this HitCross block');


            this.init('SupportedBlocks',supportedBlocks,...
            'Description',desc,...
            'Block',block);

        end

    end

    methods
        [hcOffset,hcDirectionMode]=getBlockInfo(~,hC)
        stateInfo=getStateInfo(~,~)
        val=hasDesignDelay(~,~,~)
        v=validateBlock(~,hC)
    end


    methods(Hidden)
        v_settings=block_validate_settings(this,hC)
        hNewC=elaborate(this,hN,hC)
        v=validatePortDatatypes(this,hC)
    end

end

