function copy(~)




    ed=Simulink.typeeditor.app.Editor.getInstance;

    statusMsg=DAStudio.message('Simulink:busEditor:BusEditorCopyInProgressStatusMsg');
    ed.getStudio.setStatusBarMessage(statusMsg);


    treeCompSel=ed.getCurrentTreeNode;
    assert((length(treeCompSel)==1)&&...
    (isa(treeCompSel{1},'Simulink.typeeditor.app.Object')||...
    isa(treeCompSel{1},'Simulink.typeeditor.app.Source')));
    listCompSel=ed.getCurrentListNode;

    clipboard=ed.getClipboard;
    sels=[listCompSel{:}];
    itemsToCopy={copy(sels)};
    if isa(listCompSel{1},'Simulink.typeeditor.app.Object')
        objType='object';
    else
        objType='element';
    end
    clipboard.fill(itemsToCopy,objType,{sels.Name});
    ed.update;

    statusMsg=DAStudio.message('Simulink:busEditor:BusEditorReadyStatusMsg');
    ed.getStudio.setStatusBarMessage(statusMsg);
end