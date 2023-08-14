function this=BiquadFilterHDLInstantiation(block)









    this=hdlfilterblks.BiquadFilterHDLInstantiation;

    supportedBlocks={...
    'dsparch4/Biquad Filter',...
    };

    if nargin==0
        block='';
    end


    desc=struct(...
    'ShortListing','Biquad Filter HDL instantiation',...
    'HelpText','Biquad Filter code generation via direct HDL instantiation');

    this.init('SupportedBlocks',supportedBlocks,...
    'Block',block,...
    'ArchitectureNames',{'Fully Parallel'},...
    'CodeGenMode','instantiation',...
    'Description',desc,...
    'DeprecatedArchName',{'default'});
