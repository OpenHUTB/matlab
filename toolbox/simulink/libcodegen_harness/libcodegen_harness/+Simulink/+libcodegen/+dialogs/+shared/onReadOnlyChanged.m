function onReadOnlyChanged(~,b,src,dlg)

    if~isa(dlg,'DAStudio.Dialog')
        return;
    end
    isBDEvent=~isempty(b)&&isa(b.Source,'Simulink.BlockDiagram');
    if isBDEvent
        isCCListDlg=isa(src,'Simulink.libcodegen.dialogs.codeContextListDialog');
        src.libLocked=strcmp(b.Source.Lock,'on');
        dlg.refresh();
        if isCCListDlg
            src.updateList();
            if numel(src.displayedList)==src.numChecked
                dlg.setWidgetValue('SelectAllBox',true);
                src.selectall_cb(dlg);
            end
        end
    end
end