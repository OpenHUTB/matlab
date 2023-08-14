classdef Relay<hdlimplbase.EmlImplBase



    methods
        function this=Relay(block)
            supportedBlocks={...
            'built-in/Relay',...
            };

            if nargin==0
                block='';
            end

            this.init('SupportedBlocks',supportedBlocks,...
            'Block',block,...
            'ArchitectureNames','Linear');
        end

    end

    methods
        v=validateBlock(this,hC)
    end


    methods(Hidden)
        v_settings=block_validate_settings(this,hC)
        relayComp=elaborate(this,hN,hC)
        cval=getBlockDialogValue(this,slbh,propName)
    end

end

