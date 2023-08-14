function[reply]=nativeDropOntoBlock(params,blockH)



    reply=diagram.markup.MarkupReply;
    reply.wantMarkupItem=false;
    reply.wantMarkupConnector=false;
    isUnderCUT=false;
    if rmisl.isObjectUnderCUT(blockH)
        isUnderCUT=true;
        blockObj=get(blockH,'Object');
        ownerInfo=rmisl.harnessToModelRemap(blockObj);
        blockH=ownerInfo.Handle;
    end

    if~slreq.utils.sanityCheckForDragAndDrop(blockH)
        return;
    end
    isLinkCreated=false;




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
        thisLink=slreq.utils.findLinkFromReq(reqObj,blockH);
        if~isempty(thisLink)

            continue;
        end

        if rmisl.is_signal_builder_block(blockH)
            errordlg(...
            getString(message('Slvnv:rmi:editReqs:CannotEditSigBuilder')),...
            getString(message('Slvnv:slreq:Error')));
            return;
        end
        src=slreq.utils.getRmiStruct(blockH);
        dataLink=reqObj.addLink(src);
        isLinkCreated=true;
    end

    if~isLinkCreated||~isa(params,'diagram.markup.MarkupParams')
        return;
    end

    blockPos=get_param(blockH,'Position');
    if nDroppedItem==1
        reply.targetID=blockH;
        reply.markupParams=params;


        reply.connectorItemID=dataLink.getUuid;
        reply.connectorLabel=dataLink.getForwardTypeName();

        if~isUnderCUT&&slreq.utils.isCreatingMarkup(blockH)
            blkType=get(blockH,'Type');
            needMarkup=true;
            if strcmp(blkType,'annotation')



                annotationType=get(blockH,'AnnotationType');
                isArea=strcmp(annotationType,'area_annotation');
                reply.wantGhost=isArea;
                reply.wantMarkupConnector=isArea;
                needMarkup=isArea;
            else

                reply.wantGhost=true;
                reply.wantMarkupConnector=true;
            end

            if isempty(reqObj.Markups)


                reply.wantMarkupItem=needMarkup;
                reply.markupItemPosition=[blockPos(3)+70,blockPos(2)-70];
            end
        end
    elseif nDroppedItem>1


        reply.wantGhost=false;
        reply.wantMarkupItem=false;
        reply.wantMarkupConnector=false;
        diagramObject=slreq.utils.diagramResolve(blockH);
        h=slreq.gui.PopupInformer(diagramObject,blockPos(3),blockPos(2));
        h.show();
    end
end

function postUpdate(appmgr)
    appmgr.notify('WakeUI')
    appmgr.update();
end

