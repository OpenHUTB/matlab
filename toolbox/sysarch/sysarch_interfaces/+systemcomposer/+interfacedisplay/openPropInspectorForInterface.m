function openPropInspectorForInterface()
    editor=BindMode.utils.getLastActiveEditor();
    studio=editor.getStudio();
    pi=studio.getComponent('GLUE2:PropertyInspector','Property Inspector');
    studio.showComponent(pi);
end

