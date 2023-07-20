function open(obj,buildType,pinned)




    if nargin<2
        buildType='';
    end

    if nargin<3
        pinned=-1;
    end

    st=obj.studio;
    cmp=obj.getComponent();
    if isempty(cmp)

        cv=obj.createSource();
        cv.ref=cv.ref+1;
        obj.src=cv;
        obj.lis=event.listener(cv,'CodeViewEvent',@obj.callback);


        if~isempty(buildType)
            if~strcmp(buildType,cv.buildType)
                cv.buildType=buildType;
            end
        end


        tag=obj.Tag;
        cmp=GLUE2.DDGComponent(st,tag,cv);
        cmp.setPreferredSize(400,-1);
        st.registerComponent(cmp);


        title=obj.getTitle();
        dockPosition=obj.getDockPos();
        dockOption=obj.getDockOpt();
        if pinned==false
            cmp.ShowMinimized=true;
        end
        st.moveComponentToDock(cmp,title,dockPosition,dockOption);
        if pinned==false
            cmp.ShowMinimized=false;
        end

    else
        cv=obj.src;


        if isempty(cv)
            cv=cmp.getSource;
            cv.ref=cv.ref+1;
            obj.src=cv;
            obj.lis=event.listener(cv,'CodeViewEvent',@obj.callback);
        end


        if~isempty(buildType)
            if~strcmp(buildType,cv.buildType)
                cv.buildType=buildType;
            end
        end
        cv.refresh();


        if pinned==true
            cmp.restore;
        end
        st.showComponent(cmp);
        st.setActiveComponent(cmp);
    end
