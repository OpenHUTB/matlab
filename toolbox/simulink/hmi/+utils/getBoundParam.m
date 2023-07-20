

function boundElem=getBoundParam(modelName,widgetID,isLibWidget)

    boundElem='';
    bindable=utils.getBoundElement(modelName,widgetID,isLibWidget);

    if~isempty(bindable)
        blk=bindable.BlockPath.getBlock(1);
        boundElem.blkName=get_param(blk,'Name');
        boundElem.blk=blk;
        boundElem.blkh=get_param(blk,'handle');
        boundElem.varWksType=bindable.WksType;
        if isempty(bindable.WksType)
            boundElem.isParam=1;
            boundElem.tunableParam=bindable.ParamName;
        else
            boundElem.isParam=0;
            boundElem.tunableParam=bindable.VarName;
        end
    end
end
