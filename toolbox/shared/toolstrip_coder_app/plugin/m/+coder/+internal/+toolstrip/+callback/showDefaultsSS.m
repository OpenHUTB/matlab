function showDefaultsSS(userdata,cbinfo)

    studio=cbinfo.studio;

    editor=studio.App.getActiveEditor;
    bdh=editor.blockDiagramHandle;
    simulinkcoder.internal.util.openDefaultsSS(studio,bdh);

    ss=studio.getComponent('GLUE2:SpreadSheet','DefaultsProperties');
    studio.showComponent(ss);
    ss.restore;
    studio.focusComponent(ss);

    tab=str2double(userdata);
    ss.setCurrentTab(tab);


