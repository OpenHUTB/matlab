function isUnmodified=isBlockLinkUnmodified(this,block,BlockId)







    if nargin<3

        configData=RunTimeModule_config;
        BlockId=configData.BlockId;

    end

    isUnmodified=false;
    for modParam=BlockId.Unmodified.Match

        isUnmodified=isUnmodified||(block.isprop(modParam.Param)&&strcmp(block.get(modParam.Param),modParam.Value));

        if isUnmodified
            break;
        else

        end

    end

end




