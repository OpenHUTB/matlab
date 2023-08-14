function this=DiscreteFIRFullySerial(block)









    this=hdlfilterblks.DiscreteFIRFullySerial;

    supportedBlocks={...
    'built-in/DiscreteFir',...
    };

    if nargin==0
        block='';
    end


    desc=struct(...
    'ShortListing','Discrete FIR Filter Fully Serial',...
    'HelpText','Discrete FIR Filter code generation via direct HDL instantiation');

    this.init('SupportedBlocks',supportedBlocks,...
    'Block',block,...
    'ArchitectureNames',{'Fully Serial'},...
    'CodeGenMode','instantiation',...
    'Description',desc);
