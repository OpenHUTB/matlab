function success=setParentRequirement(this,child,parent)






    childObj=this.getModelObj(child);
    if isempty(childObj)
        error('not a valid object');
    end
    if isempty(parent)

        parentObj=slreq.datamodel.RequirementItem.empty();
    else
        parentObj=this.getModelObj(parent);

        if this.isHierarchicalParent(childObj,parentObj)
            beep;
            rmiut.warnNoBacktrace('Slvnv:slreq:CannotSetAsParent',...
            sprintf('#%d',parentObj.sid),sprintf('#%d',childObj.sid));
            success=false;
            return;
        end
    end

    oldDataParent=child.parent;
    if isempty(oldDataParent)
        oldDataParent=child.getReqSet;
    end
    newDataParent=parent;
    childObj.parent=parentObj;


    modelReqSet=childObj.requirementSet;
    if(isempty(parentObj))

        if modelReqSet.rootItems.Size>0&&...
            isa(modelReqSet.rootItems.at(modelReqSet.rootItems.Size),'slreq.datamodel.Justification')


            modelReqSet.rootItems.insertAt(childObj,modelReqSet.rootItems.Size);
        else
            modelReqSet.rootItems.add(childObj);
        end
    else
        if modelReqSet.rootItems.indexOf(childObj)>0
            modelReqSet.rootItems.remove(childObj);
        end
    end


    childObj.requirementSet.updateHIdx();

    changedInfo.propName='moving';
    changedInfo.oldValue.dst=oldDataParent;
    if isempty(newDataParent)
        newDataParent=child.getReqSet;
    end
    changedInfo.newValue.dst=newDataParent;
    changedInfo.oldValue.location='on';
    changedInfo.newValue.location='on';

    this.notify('ReqDataChange',slreq.data.ReqDataChangeEvent('Requirement Moved',child,changedInfo))
    success=true;
end
