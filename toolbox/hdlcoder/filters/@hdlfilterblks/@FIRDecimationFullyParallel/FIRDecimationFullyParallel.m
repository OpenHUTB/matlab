function this=FIRDecimationFullyParallel(block)





    this=hdlfilterblks.FIRDecimationFullyParallel;

    supportedBlocks={'dspmlti4/FIR Decimation'};

    if nargin==0
        block='';
    end


    desc=struct(...
    'ShortListing','FIR Decimation Fully Parallel',...
    'HelpText','FIR Decimation code generation via direct HDL instantiation');

    this.init('SupportedBlocks',supportedBlocks,...
    'Block',block,...
    'ArchitectureNames',{'Fully Parallel'},...
    'CodeGenMode','instantiation',...
    'Description',desc);
