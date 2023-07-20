classdef ChromaResampler<visionhdlsupport.internal.AbstractVHT











    methods
        function this=ChromaResampler(block)

            supportedBlocks={...
            'visionhdlconversions/Chroma Resampler',...
            'visionhdl.ChromaResampler',...
            };

            if nargin==0
                block='';
            end

            desc=struct(...
            'ShortListing','HDL Support for Chroma Resampler',...
            'HelpText','HDL Support for Chroma Resampler');

            this.init('SupportedBlocks',supportedBlocks,...
            'Block',block,...
            'Description',desc);
        end
    end

end
