function this=DigitalFilterHDLInstantiation(block)









    this=hdlfilterblks.DigitalFilterHDLInstantiation;

    supportedBlocks={'dspobslib/Digital Filter'};

    if nargin==0
        block='';
    end


    desc=struct(...
    'ShortListing','Digital Filter HDL instantiation',...
    'HelpText','Digital Filter code generation via direct HDL instantiation');

    this.init('SupportedBlocks',supportedBlocks,...
    'Block',block,...
    'CodeGenMode','instantiation',...
    'Description',desc);
