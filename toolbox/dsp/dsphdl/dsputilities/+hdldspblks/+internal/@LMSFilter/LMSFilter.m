classdef LMSFilter<hdlimplbase.EmlImplBase




    methods
        function this=LMSFilter(block)
            supportedBlocks={...
            'dspadpt3/LMS Filter',...
            };

            if nargin==0
                block='';
            end

            desc=struct(...
            'ShortListing','HDL support for LMS Filter',...
            'HelpText','HDL support for LMS Filter');

            this.init('SupportedBlocks',supportedBlocks,...
            'Block',block,...
            'Description',desc);


        end

    end

    methods
        hdlcode=elaborate(this,hN,hC)
        v=validateBlock(this,hC)
    end


    methods(Hidden)
        v_settings=block_validate_settings(this,hC)
        params=slopeBiasParametersToCheck(this,hC)
    end

end

