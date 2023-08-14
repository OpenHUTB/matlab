classdef NoHDL<imported.hdldefaults.NoHDL










    methods
        function this=NoHDL(block)

            supportedBlocks={...
            'visionhdlutilities/Measure Timing',...
            'visionhdl.MeasureTiming',...
            };

            if nargin==0
                block='';
            end

            desc=struct(...
            'ShortListing','HDL Support for Sinks',...
            'HelpText','HDL Support for Sinks');

            this.init('SupportedBlocks',supportedBlocks,...
            'Block',block,...
            'ArchitectureNames',{'No HDL'},...
            'Description',desc);
        end
    end
end