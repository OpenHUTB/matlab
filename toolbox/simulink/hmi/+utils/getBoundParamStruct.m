

function boundElem=getBoundParamStruct(paramSource)
    boundElem='';

    if~isempty(paramSource)
        blk=paramSource.BlockPath.getBlock(1);
        boundElem.BlockPath=paramSource.BlockPath;
        boundElem.blkName=get_param(blk,'Name');
        boundElem.blk=blk;
        boundElem.blkh=get_param(blk,'handle');
        boundElem.varWksType=paramSource.WksType;
        if isempty(paramSource.WksType)
            boundElem.isParam=1;
            boundElem.tunableParam=paramSource.ParamName;
        else
            boundElem.isParam=0;
            boundElem.tunableParam=paramSource.VarName;
        end
        boundElem.BindingRule_='';
    end

end