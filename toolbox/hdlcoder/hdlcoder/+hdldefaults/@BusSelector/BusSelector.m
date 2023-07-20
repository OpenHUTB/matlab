classdef BusSelector<hdlimplbase.EmlImplBase



    methods
        function this=BusSelector(block)
            supportedBlocks={...
            'built-in/BusSelector',...
            };

            if nargin==0
                block='';
            end

            desc=struct(...
            'ShortListing','BusSelector Block Implementation',...
            'HelpText','BusSelector Block');

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

