classdef ViterbiDecoder<hdlimplbase.EmlImplBase





    methods
        function this=ViterbiDecoder(block)
            supportedBlocks={...
            'whdledac/Viterbi Decoder',...
            };

            if nargin==0
                block='';
            end

            desc=struct(...
            'ShortListing','HDL Support for ViterbiDecoder',...
            'HelpText','HDL Support for ViterbiDecoder');

            this.init('SupportedBlocks',supportedBlocks,...
            'Block',block,...
            'Description',desc,...
            'ArchitectureNames','RAM-based Traceback');
        end
    end
end