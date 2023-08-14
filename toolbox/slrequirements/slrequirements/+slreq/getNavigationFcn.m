





















function result=getNavigationFcn(sourceName)

    ncbMgr=slreq.internal.NavigationFcnRegistry.getInstance();
    if nargin==0
        result=ncbMgr.list();
    else
        result=ncbMgr.get(sourceName);
    end
end
