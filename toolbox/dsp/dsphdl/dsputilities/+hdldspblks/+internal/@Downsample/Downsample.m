classdef Downsample<hdlimplbase.EmlImplBase




    methods
        function this=Downsample(block)

            supportedBlocks={...
            'built-in/DownSample',...
            };

            if nargin==0
                block='';
            end

            desc=struct(...
            'ShortListing','HDL code generation for Downsample',...
            'HelpText','HDL code generation for Downsample');

            this.init('SupportedBlocks',supportedBlocks,...
            'Block',block,...
            'Description',desc,...
            'Deprecates',{'hdldefaults.DownsampleHDLEmission','hdldefaults.Downsample'});

        end
    end

end
