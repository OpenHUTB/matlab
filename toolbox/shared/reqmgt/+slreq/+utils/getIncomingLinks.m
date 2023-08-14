function links=getIncomingLinks(req)

    r=slreq.data.ReqData.getInstance;
    links=r.getIncomingLinks(req);

end