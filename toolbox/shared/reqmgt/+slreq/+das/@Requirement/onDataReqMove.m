function onDataReqMove(this)






    dataReq=this.dataModelObj;
    oldDasParent=this.parent;
    if~isempty(oldDasParent)


        oldDasIdx=oldDasParent.findObjectIndex(this);

        oldDasParent.children(oldDasIdx)=[];
    end

    dataParent=dataReq.parent;
    if isempty(dataParent)
        dataParent=dataReq.getReqSet();
    end
    newDataIdx=dataParent.indexOf(dataReq);


    newDasParent=dataParent.getDasObject();
    if isempty(newDasParent)


        this.parent=[];
        return;
    end
    newDasParent.insertChildObjectAt(this,newDataIdx);
end
