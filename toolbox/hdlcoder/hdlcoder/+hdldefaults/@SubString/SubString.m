classdef SubString<hdlimplbase.EmlImplBase



    methods
        function this=SubString(block)
            supportedBlocks={...
            'built-in/Substring',...
            };

            if nargin==0
                block='';
            end

            this.init('SupportedBlocks',supportedBlocks,...
            'Block',block);


        end

    end

    methods
        stateInfo=getStateInfo(this,hC)
        hNewC=elaborate(this,hN,hC)
        v_settings=block_validate_settings(this,hC)
    end


end

