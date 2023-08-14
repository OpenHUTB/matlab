function this=DiscreteFIRFilterHDLInstantiation(block)









    this=hdlfilterblks.DiscreteFIRFilterHDLInstantiation;

    supportedBlocks={...
    'built-in/DiscreteFir',...
    };

    if nargin==0
        block='';
    end


    desc=struct(...
    'ShortListing','Discrete FIR Filter HDL instantiation',...
    'HelpText','Discrete FIR Filter code generation via direct HDL instantiation');

    this.init('SupportedBlocks',supportedBlocks,...
    'Block',block,...
    'ArchitectureNames','default',...
    'CodeGenMode','instantiation',...
    'Description',desc);
