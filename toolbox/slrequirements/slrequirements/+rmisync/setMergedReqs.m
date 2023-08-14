function newLinkStr=setMergedReqs(objH,reqInfoStr,syncObj,doorsId,doorsLinkInfo)





    if isempty(reqInfoStr)
        origReqs=[];
    else
        origReqs=rmi.parsereqs(reqInfoStr);
    end

    [newReqs,newLinkStr]=rmisync.mergeLinks(origReqs,syncObj,doorsId,doorsLinkInfo);


    if~syncObj.isTesting
        updatedReqs=syncObj.updateDocNames(newReqs);
    else
        updatedReqs=newReqs;
        updatedReqs(1).doc='00000000';
    end


    rmi.setReqs(objH,updatedReqs,-1,-1);
end

