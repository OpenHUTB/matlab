classdef BustoVector<hdlimplbase.EmlImplBase



    methods
        function this=BustoVector(block)
            supportedBlocks={...
            'built-in/BusToVector',...
            };

            if nargin==0
                block='';
            end

            desc=struct(...
            'ShortListing','BusToVector Block Implementation',...
            'HelpText','BusToVector Block');

            this.init('SupportedBlocks',supportedBlocks,...
            'Block',block,...
            'Description',desc);

        end

    end

    methods
        newComp=elaborate(~,hN,hC)
        stateInfo=getStateInfo(this,hC)
        v=validateBlock(~,hC)
    end


    methods(Hidden)
        v_settings=block_validate_settings(this,hC)
    end

end

