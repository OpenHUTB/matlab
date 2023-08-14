function remove(this)

    dataReqSet=this.dataModelObj.getReqSet();
    dataReqSet.removeRequirement(this.dataModelObj);
end
