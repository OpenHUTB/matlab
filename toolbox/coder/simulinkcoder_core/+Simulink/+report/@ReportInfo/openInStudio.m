function openInStudio(obj,url)

    editor=GLUE2.Util.findAllEditors(obj.ModelName);
    studio=editor.getStudio();

    url=loc_getFileUrl(url);
    url=[url,'&inStudio=true'];
    id='code';
    if~isa(obj.WebDDG,'DAStudio.WebDDG')
        title=['Code for ',obj.ModelName];
        obj.WebDDG=DAStudio.WebDDG;
        obj.WebDDG.Url=url;
        obj.WebDDG.ToolbarOptions={'Search'};
        try
            obj.WebDDG.createEmbeddedDDG(studio,id,title,'Right','Stacked');
        catch
        end
    else
        obj.WebDDG.Url=url;
        comp=studio.getComponent('GLUE2:DDG Component',id);
        studio.showComponent(comp);
    end
end
