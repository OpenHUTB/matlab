function origBlk=getOrigRootIOPort(blk,portType)



    origBlk=blk;
    if strcmpi(get_param(blk,'BlockType'),portType)
        blkObject=get_param(blk,'Object');
        if blkObject.isSynthesized
            blkParent=get_param(get_param(blk,'Parent'),'handle');
            if strcmpi(get_param(blkParent,'Type'),'block_diagram')
                blkName=get_param(blk,'Name');
                block=find_system(blkParent,...
                'SearchDepth',1,...
                'Name',blkName);

                block=getBlockHandle(block);
                if~isempty(block)
                    origBlk=block;
                end
            end
        end
    end
end


function out=getBlockHandle(blocks)
    out=[];
    for i=1:numel(blocks)
        if~strcmpi(get_param(blocks(i),'Type'),'block_diagram')
            out(end+1)=blocks(i);%#ok<AGROW>
        end
    end
end