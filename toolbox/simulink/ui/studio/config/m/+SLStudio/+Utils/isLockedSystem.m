function locked=isLockedSystem(cbinfo)





    editor=cbinfo.studio.App.getActiveEditor;
    diagram=editor.getDiagram;
    locked=diagram.locked;
end
