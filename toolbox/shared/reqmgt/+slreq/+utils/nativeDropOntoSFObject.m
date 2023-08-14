function[reply]=nativeDropOntoSFObject(params,objectID)


    assert(isa(params,'diagram.markup.MarkupParams'))
    reply=diagram.markup.MarkupReply;
    reply.targetID=objectID;
    reply.markupParams=params;
    reply.wantMarkupItem=false;
    reply.wantMarkupConnector=false;
    if objectID==0
        return;
    end

    if~slreq.utils.sanityCheckForDragAndDrop(objectID)
        return;
    end

    objectID=double(objectID);
    if rmisl.isObjectUnderCUT(objectID)


        sr=sfroot;
        objectH=sr.idToHandle(objectID);


        ownerH=rmisl.harnessToModelRemap(objectH);
        objectID=ownerH.Id;
    end


    itemIds=strsplit(params.itemID,',');
    nDroppedItem=numel(itemIds);
    if nDroppedItem<1
        return;
    end

    appmgr=slreq.app.MainManager.getInstance;
    appmgr.notify('SleepUI');
    clp=onCleanup(@()postUpdate(appmgr));

    isLinkCreated=false;
    for n=1:nDroppedItem
        reqObj=slreq.utils.findDASbyUUID(itemIds{n});
        if isempty(reqObj)||~isa(reqObj,'slreq.das.Requirement')
            continue;
        end
        thisLink=slreq.utils.findLinkFromReq(reqObj,objectID);
        src=slreq.utils.getRmiStruct(objectID);
        if~isempty(thisLink)

            continue;
        end



        dataLink=reqObj.addLink(src);
        isLinkCreated=true;
    end

    if~isLinkCreated
        return;
    end
    if sf('get',objectID,'.isa')==5
        objectPos=sf('get',objectID,'.midPoint');
        objectPos(3)=objectPos(1);
        objectPos(4)=objectPos(2);
    else
        objectPos=sf('get',objectID,'.position');
    end
    sr=sfroot;
    objectH=sr.idToHandle(objectID);

    if nDroppedItem==1
        if~slreq.utils.isCreatingMarkup(objectID)

            return;
        end

        reply.connectorItemID=dataLink.getUuid;
        reply.connectorLabel=dataLink.getForwardTypeName();



        isAnnotation=isa(objectH,'Stateflow.Annotation');


        reply.wantGhost=~isAnnotation;

        reply.wantMarkupConnector=~isAnnotation;

        if isempty(reqObj.Markups)

            reply.wantMarkupItem=~isAnnotation;

            reply.markupItemPosition=[objectPos(1)+70,objectPos(2)-70];
        end
    elseif nDroppedItem>1


        reply.wantGhost=false;
        reply.wantMarkupItem=false;
        reply.wantMarkupConnector=false;
        diagramObject=slreq.utils.diagramResolve(objectH);
        h=slreq.gui.PopupInformer(diagramObject,objectPos(1),objectPos(2));
        h.show();
    end
end

function postUpdate(appmgr)
    appmgr.notify('WakeUI')
    appmgr.update();
end