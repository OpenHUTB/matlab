classdef SwitchCase<hdlimplbase.EmlImplBase




    methods
        function this=SwitchCase(block)
            supportedBlocks={...
            'built-in/SwitchCase',...
            };

            if nargin==0
                block='';
            end

            this.init('SupportedBlocks',supportedBlocks,...
            'Block',block);
        end
    end

    methods
        newComp=elaborate(~,hN,hC)
        v_settings=block_validate_settings(~,~)
        v=validateBlock(~,hC)
        retval=allowElabModelGen(~,~,~)
        retval=forceElabModelGen(~,~,~)
    end
end
