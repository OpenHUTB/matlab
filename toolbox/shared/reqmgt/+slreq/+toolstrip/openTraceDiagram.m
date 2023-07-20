function openTraceDiagram(cbinfo)

    selection='';

    if slreq.toolstrip.isEditor(cbinfo)
        editor=slreq.app.MainManager.getInstance.requirementsEditor;
        if~isempty(editor)
            selection=editor.getCurrentSelection;
        end
    else

        rootmodel=slreq.toolstrip.getModelHandle(cbinfo);
        mainmgr=slreq.app.MainManager.getInstance;
        editor=mainmgr.getSpreadSheetObject(rootmodel);
        if~isempty(editor)
            selection=editor.currentSelectedObj;
        end
    end

    if isa(selection,'slreq.das.Requirement')||...
        isa(selection,'slreq.das.Link')||...
        isa(selection,'slreq.das.LinkSet')||...
        isa(selection,'slreq.das.RequirementSet')
        slreq.internal.gui.Editor.generateTraceDiagram(selection);
    end

end


