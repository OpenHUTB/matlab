function show(obj,input,minimize)


    if nargin<3
        minimize=false;
    end

    src=simulinkcoder.internal.util.getSource(input);
    studio=src.studio;
    if isempty(studio)

        DAStudio.Dialog(obj);
        return;
    end

    id=obj.id;
    title=obj.title;
    dockposition='Left';
    dockoption='Tabbed';

    cmpName=obj.comp;
    cmp=studio.getComponent(cmpName,id);
    if isempty(cmp)
        cmp=GLUE2.DDGComponent(studio,id,obj);
        cmp.ShowMinimized=minimize;
        studio.registerComponent(cmp);
        studio.moveComponentToDock(cmp,title,dockposition,dockoption);
        cmp.ShowMinimized=false;
    else
        mdlH=src.modelH;
        cp=simulinkcoder.internal.CodePerspective.getInstance;
        [~,target]=cp.getInfo(mdlH);
        obj.refresh(mdlH,target);
        cmp.ShowMinimized=minimize;
        studio.showComponent(cmp);
        cmp.ShowMinimized=false;
    end



