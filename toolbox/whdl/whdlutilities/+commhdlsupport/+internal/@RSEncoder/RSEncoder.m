classdef RSEncoder<hdlimplbase.EmlImplBase





    methods
        function this=RSEncoder(block)

            supportedBlocks={...
            'whdledac/RS Encoder'};

            if nargin==0
                block='';
            end

            desc=struct(...
            'ShortListing','HDL Support for Reed-Solomon Encoder',...
            'HelpText','HDL Support for Reed-Solomon Encoder');

            this.init('SupportedBlocks',supportedBlocks,...
            'Block',block,...
            'Description',desc);
        end
    end
end