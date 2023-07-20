function this=BiquadFilterFullySerial(block)









    this=hdlfilterblks.BiquadFilterFullySerial;

    supportedBlocks={...
    'dsparch4/Biquad Filter',...
    };

    if nargin==0
        block='';
    end


    desc=struct(...
    'ShortListing','Biquad Filter Fully Serial',...
    'HelpText','Biquad Filter code generation via direct HDL instantiation');

    this.init('SupportedBlocks',supportedBlocks,...
    'Block',block,...
    'ArchitectureNames',{'Fully Serial'},...
    'CodeGenMode','instantiation',...
    'Description',desc);
