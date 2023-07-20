classdef ChannelEstimator<hdlimplbase.HDLRecurseIntoSubsystem




    methods
        function this=ChannelEstimator(block)

            supportedBlocks={...
            'whdlmod/OFDM Channel Estimator',...
            };

            if nargin==0
                block='';
            end

            desc=struct('ShortListing','Generate HDL Code for OFDM Channel Estimator Block',...
            'HelpText','HDL will be emitted for the OFDM Channel Estimator block');

            this.init('SupportedBlocks',supportedBlocks,...
            'Description',desc,...
            'Block',block,...
            'ArchitectureNames','default');
        end
    end
end