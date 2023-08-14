function showEmbedded(obj)



    studio=obj.studio;
    id=obj.id;
    title=obj.title;
    dockposition='Left';
    dockoption='Tabbed';

    cmpName=obj.comp;
    comp=studio.getComponent(cmpName,id);
    if isempty(comp)
        DAStudio.openEmbeddedDDGForSource(studio,obj,id,title,dockposition,dockoption);
    else
        studio.showComponent(comp);
        studio.setActiveComponent(comp);
    end
