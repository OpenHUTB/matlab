classdef If<hdlimplbase.EmlImplBase





    methods
        function this=If(block)
            supportedBlocks={...
            'built-in/If',...
            };

            if nargin==0
                block='';
            end

            this.init('SupportedBlocks',supportedBlocks,...
            'Block',block);
        end
    end

    methods
        v_settings=block_validate_settings(~,~);
        hNewC=elaborate(this,hN,hC);
        v=validateBlock(~,hC);
        retval=allowElabModelGen(~,~,~)
        retval=forceElabModelGen(~,~,~)
    end
end
