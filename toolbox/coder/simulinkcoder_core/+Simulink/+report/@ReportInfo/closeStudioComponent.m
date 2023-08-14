function closeStudioComponent(obj)
    id='code';
    try
        editor=GLUE2.Util.findAllEditors(obj.ModelName);
        studio=editor.getStudio();
        comp=studio.getComponent('GLUE2:DDG Component',id);
        studio.destroyComponent(comp);
    catch
    end
end
