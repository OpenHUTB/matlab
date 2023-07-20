function[reply]=nativeDropOntoZCPort(params,portH)



    reply=diagram.markup.MarkupReply;
    reply.wantMarkupItem=false;
    reply.wantMarkupConnector=false;
    isUnderCUT=false;
    if rmisl.isObjectUnderCUT(portH)
        isUnderCUT=true;
        blockObj=get(portH,'Object');
        ownerInfo=rmisl.harnessToModelRemap(blockObj);
        portH=ownerInfo.Handle;
    end

    if~slreq.utils.sanityCheckForDragAndDrop(portH)
        return;
    end

    zcPort=systemcomposer.utils.getArchitecturePeer(portH);
    if isa(zcPort,'systemcomposer.architecture.model.design.ComponentPort')
        parentComp=zcPort.getComponent;
        if~parentComp.isReferenceComponent&&~parentComp.isImplComponent
            zcPort=zcPort.getArchitecturePort;
        end
    end
    zcPort=systemcomposer.utils.getSimulinkPeer(zcPort);


    itemIds=strsplit(params.itemID,',');
    nDroppedItem=numel(itemIds);
    if nDroppedItem<1
        return;
    end

    appmgr=slreq.app.MainManager.getInstance;
    appmgr.notify('SleepUI');
    clp=onCleanup(@()postUpdate(appmgr));

    for n=1:nDroppedItem
        reqObj=slreq.utils.findDASbyUUID(itemIds{n});
        if isempty(reqObj)||~isa(reqObj,'slreq.das.Requirement')

            continue;
        end
        thisLink=slreq.utils.findLinkFromReq(reqObj,zcPort);
        if~isempty(thisLink)

            continue;
        end

        src=slreq.utils.getRmiStruct(zcPort);
        dataLink=reqObj.addLink(src);

        if(isa(params,'diagram.markup.MarkupParams'))



            reply.targetID=portH;
            reply.markupParams=params;


            reply.connectorItemID=dataLink.getUuid;
            reply.connectorLabel=dataLink.getForwardTypeName();

            if~isUnderCUT&&slreq.utils.isCreatingMarkup(portH)

                reply.wantGhost=true;

                if isempty(reqObj.Markups)


                    blockPos=get_param(portH,'Position');
                    reply.markupItemPosition=[blockPos(1)+70,blockPos(2)-70];
                end
            end
        end
    end
end

function postUpdate(appmgr)
    appmgr.notify('WakeUI')
    appmgr.update();
end

