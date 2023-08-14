function updateParent(this)







    thisIndex=this.findChildIndex();
    this.parent.children(thisIndex)=[];


    newParent=this.dataModelObj.parent;
    if isempty(newParent)

        newParent=this.dataModelObj.getReqSet();
        dataSibling=newParent.children;
        numSibling=length(dataSibling);
        if numSibling>1&&dataSibling(numSibling).isJustification

            newParent.getDasObject().insertChildObjectAt(this,numSibling-1);
            return;
        end
    end

    newParentDas=newParent.getDasObject();
    newParentDas.addChildObject(this);

end
