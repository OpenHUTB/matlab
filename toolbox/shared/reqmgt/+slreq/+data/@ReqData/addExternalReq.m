

function mfReq=addExternalReq(this,group,reqInfo)






    mfReqSet=group.requirementSet;

    mfReq=this.createExternalRequirement(reqInfo);
    this.setCustomAttributesForNewReq(mfReq,mfReqSet,reqInfo);

    group.items.add(mfReq);


    mfReqSet.addItem(mfReq);




    this.setUniqueCustomId(group,mfReq);




    group.externalReqs.add(mfReq);
end
