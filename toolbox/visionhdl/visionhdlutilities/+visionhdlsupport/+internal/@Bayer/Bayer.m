classdef Bayer<visionhdlsupport.internal.AbstractVHT










    methods
        function this=Bayer(block)

            supportedBlocks={...
            'visionhdlconversions/Demosaic Interpolator',...
'visionhdl.DemosaicInterpolator'...
            };

            if nargin==0
                block='';
            end


            desc=struct(...
            'ShortListing','HDL Support for Demosaic HDL Optimized',...
            'HelpText','HDL Support for Demosaic HDL Optimized');

            this.init('SupportedBlocks',supportedBlocks,...
            'Block',block,...
            'Description',desc);
        end
    end

end
