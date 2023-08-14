function this=FIRDecimationHDLInstantiation(block)









    this=hdlfilterblks.FIRDecimationHDLInstantiation;

    supportedBlocks={...
    'dspmlti4/FIR Decimation'};

    if nargin==0
        block='';
    end


    desc=struct(...
    'ShortListing','FIR Decimation HDL instantiation',...
    'HelpText','FIR Decimation code generation via direct HDL instantiation');

    this.init('SupportedBlocks',supportedBlocks,...
    'Block',block,...
    'ArchitectureNames','default',...
    'CodeGenMode','instantiation',...
    'Description',desc);
