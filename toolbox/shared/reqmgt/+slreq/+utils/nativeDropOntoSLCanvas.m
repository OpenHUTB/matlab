function[reply]=nativeDropOntoSLCanvas(params,graphH)


    assert(isa(params,'diagram.markup.MarkupParams'))
    reply=diagram.markup.MarkupReply;
    reply.targetID=graphH;
    reply.markupParams=params;
    reply.wantMarkupItem=false;
    reply.wantMarkupConnector=false;
    reply.markupItemPosition=params.scenePosition(1:2);
    if~slreq.utils.sanityCheckForDragAndDrop(graphH)
        return;
    end

    if rmisl.isObjectUnderCUT(graphH)


        graphObj=get(graphH,'Object');
        ownerInfo=rmisl.harnessToModelRemap(graphObj);
        graphH=ownerInfo.Handle;
        if~slreq.utils.sanityCheckForDragAndDrop(graphH)
            return;
        end
    elseif slreq.utils.isCreatingMarkup(graphH)
        reply.wantMarkupItem=true;
        reply.wantMarkupConnector=true;
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
        thisLink=slreq.utils.findLinkFromReq(reqObj,graphH);
        if~isempty(thisLink)

            continue;
        end
        src=slreq.utils.getRmiStruct(graphH);
        dataLink=reqObj.addLink(src);
        isLinkCreated=true;
    end

    if~isLinkCreated||nDroppedItem<1
        return;
    end

    if nDroppedItem==1

        reply.connectorItemID=dataLink.getUuid;
        reply.connectorLabel=dataLink.getForwardTypeName();
    elseif nDroppedItem>1


        reply.wantGhost=false;
        reply.wantMarkupItem=false;
        reply.wantMarkupConnector=false;
        diagramObject=slreq.utils.diagramResolve(graphH);
        h=slreq.gui.PopupInformer(diagramObject,1,1);
        h.show();
    end
end

function postUpdate(appmgr)
    appmgr.notify('WakeUI')
    appmgr.update();
end

