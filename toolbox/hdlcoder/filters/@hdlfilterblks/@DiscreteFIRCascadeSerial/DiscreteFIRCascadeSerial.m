function this=DiscreteFIRCascadeSerial(block)









    this=hdlfilterblks.DiscreteFIRCascadeSerial;

    supportedBlocks={...
    'built-in/DiscreteFir',...
    };

    if nargin==0
        block='';
    end


    desc=struct(...
    'ShortListing','Discrete FIR Filter Cascade Serial',...
    'HelpText','Discrete FIR Filter code generation via direct HDL instantiation');

    this.init('SupportedBlocks',supportedBlocks,...
    'Block',block,...
    'ArchitectureNames',{'Cascade Serial'},...
    'CodeGenMode','instantiation',...
    'Description',desc);
