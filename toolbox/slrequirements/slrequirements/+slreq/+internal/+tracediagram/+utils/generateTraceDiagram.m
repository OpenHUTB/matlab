function generateTraceDiagram(dataReqOrLink)


    dmgr=slreq.internal.tracediagram.utils.DiagramManager.getInstance;
    if nargin==0
        dasObj=slreq.app.MainManager.getCurrentObject;
        dataReqOrLink=dasObj.dataModelObj;
    end

    dmgr.openWindow(dataReqOrLink);
end

