function this=CICDecimationHDLInstantiation(block)








    this=hdlfilterblks.CICDecimationHDLInstantiation;

    supportedBlocks={...
    ['dspmlti4/CIC Decimation'],...
    ['dspobslib/CIC Decimation'],...
    };

    if nargin==0
        block='';
    end


    desc=struct(...
    'ShortListing','CIC Decimation HDL instantiation',...
    'HelpText','CIC Decimation code generation via direct HDL instantiation');

    this.init('SupportedBlocks',supportedBlocks,...
    'Block',block,...
    'CodeGenMode','instantiation',...
    'Description',desc);
