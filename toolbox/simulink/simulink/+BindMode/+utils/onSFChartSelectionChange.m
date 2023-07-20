

function onSFChartSelectionChange(~,selectionBackendIds,selectionPosition)

    bMObj=BindMode.BindMode.getInstance();
    bMSourceDataObj=bMObj.bindModeSourceDataObj;
    selectionTypes=cell(1,numel(selectionBackendIds));
    if numel(selectionBackendIds)>1
        selectionStyle=BindMode.SelectionStyleEnum.MARQUEE;
    else
        selectionStyle=BindMode.SelectionStyleEnum.SINGLE;
    end
    for i=1:numel(selectionBackendIds)
        selectionTypes{i}=BindMode.utils.getSFSelectionType(selectionBackendIds(i));
    end
    bMSourceDataObj.onSFChartSelectionChange(selectionStyle,...
    selectionTypes,selectionBackendIds,selectionPosition);
end