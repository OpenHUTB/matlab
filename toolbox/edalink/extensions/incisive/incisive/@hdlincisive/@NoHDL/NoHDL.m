function this=NoHDL(block)









    this=hdlincisive.NoHDL;

    supportedBlocks={...
    'lfilinklib/To VCD File',...
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
