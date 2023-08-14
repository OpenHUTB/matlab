

function onModelSelectionChange(modelHandle,selectionHandles,selectionPosition,blockPosition)

    bMObj=BindMode.BindMode.getInstance();
    bMSourceDataObj=bMObj.bindModeSourceDataObj;
    selectionTypes=cell(1,numel(selectionHandles));
    if(numel(selectionHandles)>1)
        selectionStyle=BindMode.SelectionStyleEnum.MARQUEE;
    else
        selectionStyle=BindMode.SelectionStyleEnum.SINGLE;
    end
    for i=1:numel(selectionHandles)
        type=get(selectionHandles(i),'Type');
        if strcmp(type,'port')
            selectionTypes{i}=BindMode.SelectionTypeEnum.SLSIGNAL;
        elseif strcmp(type,'block')
            selectionTypes{i}=BindMode.SelectionTypeEnum.SLBLOCK;
        elseif strcmp(type,'root')
            selectionTypes{i}=BindMode.SelectionTypeEnum.NONE;
        end
    end
    bMSourceDataObj.onModelSelectionChange(selectionStyle,...
    selectionTypes,selectionHandles,selectionPosition,blockPosition);
end