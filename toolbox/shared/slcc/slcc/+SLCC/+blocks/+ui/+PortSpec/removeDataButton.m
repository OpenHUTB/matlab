function removeDataButton(dialog,source,varargin)


    spSheet=dialog.getWidgetInterface('csb_portSpec_spreadsheet_tag');
    selects=spSheet.getSelection;
    if isempty(selects)
        errmsg=MException(message('Simulink:CustomCode:CFunctionBlockUINoSelectionForRemove'));
        throw(errmsg);
    end

    deleteSelectedData(dialog,source,selects);

end

function deleteSelectedData(dialog,source,selects)
    block=source.getBlock();
    obj=get_param(block.Handle,'SymbolSpec');
    for i=1:numel(selects)
        deletedNames{i}=selects{i}.m_ArgName;
    end
    for i=1:numel(selects)


        dialog.setEnabled('pushbuttonTagRemove',true);
        obj.deleteSymbol(deletedNames{i});
    end
end