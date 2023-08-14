function this=FIRInterpolationFullySerial(block)




    this=hdlfilterblks.FIRInterpolationFullySerial;

    supportedBlocks={...
'dspmlti4/FIR Interpolation'...
    };

    if nargin==0
        block='';
    end

    desc=struct(...
    'ShortListing','FIR Interpolation Fully Serial Implementation',...
    'HelpText','FIR Interpolation code generation via direct HDL instantiation');

    this.init('SupportedBlocks',supportedBlocks,...
    'Block',block,...
    'ArchitectureNames',{'Fully Serial'},...
    'CodeGenMode','instantiation',...
    'Description',desc);
