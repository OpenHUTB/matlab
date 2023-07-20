function groups=collectGroupsInMLFB(runObj,result)




    autoscalerMetaData=runObj.getMetaData;
    if~isempty(autoscalerMetaData)

        uniqueID=result.UniqueIdentifier;
        res_daobject=uniqueID.getObject;
        blkObjPath=res_daobject.MATLABFunctionIdentifier.SID;


        mlfbResultsMap=autoscalerMetaData.getMLFBResultsMap;
        results=mlfbResultsMap.getDataByKey(blkObjPath);


        groups=cellfun(@(x)(runObj.dataTypeGroupInterface.getGroupForResult(x)),results,'UniformOutput',false);
    end
end
