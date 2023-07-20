function this=DiscreteFIRFrameBased(block)









    this=hdlfilterblks.DiscreteFIRFrameBased;

    supportedBlocks={...
    'built-in/DiscreteFir',...
    };

    if nargin==0
        block='';
    end


    desc=struct(...
    'ShortListing','Discrete FIR Filter Frame Based',...
    'HelpText','Discrete FIR Filter code generation, frame based input, direct HDL instantiation');

    this.init('SupportedBlocks',supportedBlocks,...
    'Block',block,...
    'ArchitectureNames',{'Frame Based'},...
    'CodeGenMode','instantiation',...
    'Description',desc);
