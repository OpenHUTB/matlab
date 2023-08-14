function this=SystemBlock(block)




    this=hdldefaults.SystemBlock;

    supportedBlocks={...
    'built-in/MATLABSystem',...
    };

    if nargin==0
        block='';
    end

    this.init('SupportedBlocks',supportedBlocks,...
    'Block',block,...
    'ArchitectureNames','MATLAB System',...
    'Deprecates',{});
