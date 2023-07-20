function[tf,pendingUpdateStruct]=moveRequirement(this,movedDataReq,location,dstDataReq,pendingUpdateStruct)






    tf=false;
    if nargin<5
        pendingUpdateStruct=[];
    end

    if~any(strcmp(location,{'before','after','on'}))

        return;
    end
    if movedDataReq==dstDataReq

        return;
    end
    if isa(dstDataReq,'slreq.data.Requirement')||isa(dstDataReq,'slreq.data.RequirementSet')
        dstItem=this.getModelObj(dstDataReq);
    elseif isa(dstDataReq,'slreq.datamodel.RequirementItem')
        dstItem=dstDataReq;
    else

        return;
    end












    if isa(movedDataReq,'slreq.data.Requirement')
        moveItem=this.getModelObj(movedDataReq);
        needToNotify=true;
    elseif isa(movedDataReq,'slreq.datamodel.RequirementItem')
        needToNotify=false;
        moveItem=movedDataReq;
    else

        return;
    end

    if(needToNotify)

        oldDataParent=movedDataReq.parent;
        if isempty(oldDataParent)
            oldDataParent=movedDataReq.getReqSet;
        end
    end
    if~isempty(moveItem.parent)

        moveSiblings=moveItem.parent.children;
    else

        moveSiblings=moveItem.requirementSet.rootItems;
    end

    moveSiblings.remove(moveItem);

    srcReqSet=moveItem.requirementSet;
    if isa(dstItem,'slreq.datamodel.RequirementSet')
        dstReqSet=dstItem;
    else
        dstReqSet=dstItem.requirementSet;
    end

    if srcReqSet~=dstReqSet
        recMoveAcrossReqSet(moveItem,srcReqSet,dstReqSet);
    end

    if strcmp(location,'on')
        if isa(dstItem,'slreq.datamodel.RequirementSet')
            rootSize=dstItem.rootItems.Size;
            if rootSize>0


                lastObj=dstItem.rootItems.at(rootSize);
                if isa(lastObj,'slreq.datamodel.Justification')
                    dstItem.rootItems.insertAt(moveItem,rootSize);
                else
                    dstItem.rootItems.add(moveItem);
                end
            else
                dstItem.rootItems.add(moveItem);
            end
        else
            dstItem.children.add(moveItem);
        end
    else

        if~isempty(dstItem.parent)

            dstSiblings=dstItem.parent.children;
        else

            dstSiblings=dstItem.requirementSet.rootItems;
        end

        idx=dstSiblings.indexOf(dstItem);
        if idx>0
            if strcmp(location,'after')
                dstSiblings.insertAt(moveItem,idx+1);
            else
                dstSiblings.insertAt(moveItem,idx);
            end
        else


            assert(false,'Move before/after called for non-sibling');
        end
    end


    srcReqSet.updateHIdx;
    srcDataReqSet=this.wrap(srcReqSet);
    srcDataReqSet.setDirty(true);
    if srcReqSet~=dstReqSet
        dstReqSet.updateHIdx;
        dstDataReqSet=this.wrap(dstReqSet);
        dstDataReqSet.setDirty(true);
    end

    movedDataReq=this.wrap(moveItem);

    if needToNotify
        changedInfo.propName='moving';
        changedInfo.oldValue.dst=oldDataParent;
        changedInfo.newValue.dst=dstDataReq;
        changedInfo.oldValue.location='on';
        changedInfo.newValue.location=location;

        if isempty(pendingUpdateStruct)

            this.notify('ReqDataChange',slreq.data.ReqDataChangeEvent('Requirement Moved',movedDataReq,changedInfo));
        else
            pendingUpdateStruct.movedDataReqs{end+1}=movedDataReq;
            pendingUpdateStruct.changedInfos{end+1}=changedInfo;
            if pendingUpdateStruct.doNotify
                this.notify('ReqDataChange',slreq.data.ReqDataBatchChangeEvent('Requirements Moved',...
                pendingUpdateStruct.movedDataReqs,pendingUpdateStruct.changedInfos));
            end
        end
    end
    tf=true;
end

function recMoveAcrossReqSet(moveItem,srcReqSet,dstReqSet)


    srcReqSet.items.remove(moveItem);




    dstReqSet.addItem(moveItem);


    cleanupAttributeItems(moveItem,dstReqSet);


    ch=moveItem.children.toArray();
    for n=1:length(ch)
        recMoveAcrossReqSet(ch(n),srcReqSet,dstReqSet);
    end
end


function cleanupAttributeItems(moveItem,dstReqSet)






    keys=moveItem.attributeItems.keys();
    for i=1:length(keys)
        attrName=keys{i};
        attrReg=dstReqSet.attributeRegistry.getByKey(attrName);
        keepAttrItem=false;

        if~isempty(attrReg)
            attrItem=moveItem.attributeItems.getByKey(attrName);
            switch class(attrItem)
            case 'slreq.datamodel.StrAttrItem'
                keepAttrItem=attrReg.typeName==slreq.datamodel.AttributeRegType.Edit;
            case 'slreq.datamodel.BoolAttrItem'
                keepAttrItem=attrReg.typeName==slreq.datamodel.AttributeRegType.Checkbox;
            case 'slreq.datamodel.IntAttrItem'

                keepAttrItem=attrReg.typeName==slreq.datamodel.AttributeRegType.Edit;

            case 'slreq.datamodel.EnumAttrItem'
                if attrReg.typeName==slreq.datamodel.AttributeRegType.Combobox

                    keepAttrItem=attrItem.registry.entries.Size==attrReg.entries.Size&&...
                    all(strcmp(attrItem.registry.entries.toArray,attrReg.entries.toArray));
                end
            case 'slreq.datamodel.DateTimeAttrItem'
                keepAttrItem=attrReg.typeName==slreq.datamodel.AttributeRegType.DateTime;
            end
        end
        if~keepAttrItem
            moveItem.attributeItems.remove(attrItem);
        else

            attrItem.registry=attrReg;
        end
    end
end
