function this=FIRDecimationFullySerial(block)





    this=hdlfilterblks.FIRDecimationFullySerial;

    supportedBlocks={'dspmlti4/FIR Decimation'};

    if nargin==0
        block='';
    end


    desc=struct(...
    'ShortListing','FIR Decimation Fully Serial',...
    'HelpText','FIR Decimation code generation via direct HDL instantiation');

    this.init('SupportedBlocks',supportedBlocks,...
    'Block',block,...
    'ArchitectureNames',{'Fully Serial'},...
    'CodeGenMode','instantiation',...
    'Description',desc);
