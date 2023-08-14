function this=FIRDecimationFrameBased(block)









    this=hdlfilterblks.FIRDecimationFrameBased;

    supportedBlocks={...
    ['dspmlti4/FIR',10,'Decimation'],...
    };

    if nargin==0
        block='';
    end


    desc=struct(...
    'ShortListing','FIR Decimation Filter Frame Based',...
    'HelpText','FIR Decimation Filter code generation, frame based input, direct HDL instantiation');

    this.init('SupportedBlocks',supportedBlocks,...
    'Block',block,...
    'ArchitectureNames',{'Frame Based'},...
    'CodeGenMode','instantiation',...
    'Description',desc);
