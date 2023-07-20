function this=DiscreteFIRFullyParallel(block)









    this=hdlfilterblks.DiscreteFIRFullyParallel;

    supportedBlocks={...
    'built-in/DiscreteFir',...
    };

    if nargin==0
        block='';
    end


    desc=struct(...
    'ShortListing','Discrete FIR Filter Fully Parallel',...
    'HelpText','Discrete FIR Filter code generation via direct HDL instantiation');

    this.init('SupportedBlocks',supportedBlocks,...
    'Block',block,...
    'ArchitectureNames',{'Fully Parallel'},...
    'CodeGenMode','instantiation',...
    'Description',desc);
