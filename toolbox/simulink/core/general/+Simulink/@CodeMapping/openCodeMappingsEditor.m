







function openCodeMappingsEditor(model,tabIndex)
    if~isequal(get_param(model,'Open'),'on')

        return;
    end

    src=simulinkcoder.internal.util.getSource(model);
    studio=src.studio;


    cp=simulinkcoder.internal.CodePerspective.getInstance;
    cp.turnOnPerspective(studio);


    editor=studio.App.getActiveEditor;
    bdh=editor.blockDiagramHandle;
    simulinkcoder.internal.util.openCodeMappingSS(studio,bdh);
    ss=studio.getComponent('GLUE2:SpreadSheet','CodeProperties');
    ss.restore;


    pi=studio.getComponent('GLUE2:PropertyInspector','Property Inspector');
    studio.showComponent(pi);
    pi.restore;


    ss.setCurrentTab(tabIndex);
end
