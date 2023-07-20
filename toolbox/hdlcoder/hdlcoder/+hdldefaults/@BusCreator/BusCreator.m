classdef BusCreator<hdlimplbase.EmlImplBase



    methods
        function this=BusCreator(block)
            supportedBlocks={...
            'built-in/BusCreator',...
            };

            if nargin==0
                block='';
            end

            desc=struct(...
            'ShortListing','BusCreator Block Implementation',...
            'HelpText','BusCreator Block');

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

