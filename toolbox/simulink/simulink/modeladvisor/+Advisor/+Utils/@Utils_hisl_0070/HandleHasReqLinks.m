function bRes=HandleHasReqLinks(obj)


    objH=Advisor.Utils.Utils_hisl_0070.getHandleFromObject(obj);
    bRes=rmi.objHasReqs(objH,[]);
    if~bRes&&obj.isprop('LinkStatus')&&~strcmp(obj.LinkStatus,'none')
        bRes=~isempty(rmi.getReqs(objH,true));
    end
end