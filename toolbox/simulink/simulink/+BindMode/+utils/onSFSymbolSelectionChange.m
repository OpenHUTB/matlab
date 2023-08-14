

function onSFSymbolSelectionChange(backendIds)

    if isempty(backendIds)
        return;
    end


    selectionStyle=BindMode.SelectionStyleEnum.SINGLE;
    selectionTypes=cell(1,numel(backendIds));
    for i=1:numel(backendIds)
        selectionTypes{i}=BindMode.utils.getSFSelectionType(backendIds(i));
    end


    selectionPosition=BindMode.utils.getCurrentMousePosition();
    bMObj=BindMode.BindMode.getInstance();
    bMSourceDataObj=bMObj.bindModeSourceDataObj;
    bMSourceDataObj.onSFChartSelectionChange(selectionStyle,...
    selectionTypes,backendIds,selectionPosition);
end