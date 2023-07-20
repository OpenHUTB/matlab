function[blockName,blockHandle]=nesl_errorblock(baseBlock)







    blockHandle=get_param(baseBlock,'Handle');
    while~lIsBlockDiagram(blockHandle)&&~lIsSimscapeContainerBlock(blockHandle)
        blockHandle=get_param(get_param(blockHandle,'Parent'),'Handle');
    end

    blockName='';
    if lIsSimscapeContainerBlock(blockHandle)
        blockName=getfullname(blockHandle);
    else
        blockHandle=-1.0;
    end
end

function isBlockDiagram=lIsBlockDiagram(block)
    isBlockDiagram=strcmp(get_param(block,'Type'),'block_diagram');
end

function isContainer=lIsSimscapeContainerBlock(block)
    isContainer=(strcmp(get_param(block,'BlockType'),'SubSystem')&&...
    strcmp(get_param(block,'Opaque'),'on'));
end

