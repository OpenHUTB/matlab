function currelem=addchild(handle,entryobject,isadded,varargin)










    me=TflDesigner.getexplorer;
    if~me.getRoot.iseditorbusy
        me.getRoot.iseditorbusy=true;


        child=TflDesigner.elements(handle,entryobject,isadded);

        if isempty(handle.children)
            handle.children=child;
        else
            handle.children(end+1)=child;
        end

        if~isempty(varargin)
            refreshCache=logical(varargin{1});
        else
            refreshCache=false;
        end

        me.getRoot.refreshchildrencache(refreshCache);

        handle.currentelement=child.handle;

        handle.firehierarchychanged;

        currelem=child;

        me.getRoot.iseditorbusy=false;
    end
