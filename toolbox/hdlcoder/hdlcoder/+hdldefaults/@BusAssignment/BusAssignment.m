classdef BusAssignment<hdlimplbase.EmlImplBase



    methods
        function this=BusAssignment(block)
            supportedBlocks={...
            'built-in/BusAssignment',...
            };

            if nargin==0
                block='';
            end

            desc=struct(...
            'ShortListing','BusAssignment Block Implementation',...
            'HelpText','BusAssignment Block');

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

