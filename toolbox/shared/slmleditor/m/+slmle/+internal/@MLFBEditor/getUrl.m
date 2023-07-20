function url=getUrl(obj)




    m=slmle.internal.slmlemgr.getInstance;
    url=m.getUrl(obj.objectId);

    query=sprintf('eid=%d',obj.eid);
    url=[url,'&',query];
