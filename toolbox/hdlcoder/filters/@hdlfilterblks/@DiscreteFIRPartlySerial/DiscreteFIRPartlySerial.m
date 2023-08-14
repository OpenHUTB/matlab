function this=DiscreteFIRPartlySerial(block)









    this=hdlfilterblks.DiscreteFIRPartlySerial;

    supportedBlocks={...
    'built-in/DiscreteFir',...
    };

    if nargin==0
        block='';
    end


    desc=struct(...
    'ShortListing','Discrete FIR Filter Partly Serial',...
    'HelpText','Discrete FIR Filter code generation via direct HDL instantiation');

    this.init('SupportedBlocks',supportedBlocks,...
    'Block',block,...
    'ArchitectureNames',{'Partly Serial'},...
    'CodeGenMode','instantiation',...
    'Description',desc);
