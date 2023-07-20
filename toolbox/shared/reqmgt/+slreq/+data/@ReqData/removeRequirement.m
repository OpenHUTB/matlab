function[dasObjList,numOfDeletedDataReqs]=removeRequirement(this,requirement)







    dasObjList={};

    slreq.utils.assertValid(requirement);

    if~isa(requirement,'slreq.data.Requirement')
        error('Invalid argument: expected slreq.data.Requirement');
    end

    dataReqSet=this.getParentReqSet(requirement);

    mfReq=requirement.getModelObj();
    eventData1.reqObj=requirement;







    dataObjs=slreq.cpputils.collectTags(mfReq,true,true);
    uuids={};


    for i=1:length(dataObjs)
        dataObj=dataObjs{i};

        uuids{end+1}=dataObj.getUuid();%#ok<AGROW>
        dasObj=dataObj.getDasObject();
        if~isempty(dasObj)


            dasObjList{end+1}=dasObj;%#ok<AGROW>
        end
    end


    eventData1.uuids=uuids;


    eventData1.dasObjs=dasObjList;

    eventData1.dataObjs=dataObjs;



    this.notify('ReqDataChange',slreq.data.ReqDataChangeEvent('BeforeDeleteRequirement',eventData1));















    dasReq=requirement.getDasObject();




    eventData2.dasObj=dasReq;


    eventData2.dasObjList=dasObjList;






    numOfDeletedDataReqs=requirement.getNumOfDescendants();
    dataObjsWithDeletedMf0=requirement.destroyContentsAndChildren();

    for index=1:length(dataObjsWithDeletedMf0)
        cDataReq=dataObjsWithDeletedMf0{index};
        cDataReq.delete();
    end



    dataReqSet.setDirty(true);


    this.notify('ReqDataChange',slreq.data.ReqDataChangeEvent('Pre Requirement Deleted',eventData2));
    this.notify('ReqDataChange',slreq.data.ReqDataChangeEvent('Requirement Deleted',eventData2));

    dataReqSet.updateHIdx();
end
