function this=DiscreteFIRDA(block)









    this=hdlfilterblks.DiscreteFIRDA;

    supportedBlocks={...
    'built-in/DiscreteFir',...
    };

    if nargin==0
        block='';
    end


    desc=struct(...
    'ShortListing','Discrete FIR Filter Distributed Arithmetic',...
    'HelpText','Discrete FIR Filter code generation via direct HDL instantiation');

    this.init('SupportedBlocks',supportedBlocks,...
    'Block',block,...
    'ArchitectureNames',{'Distributed Arithmetic (DA)'},...
    'CodeGenMode','instantiation',...
    'Description',desc);
