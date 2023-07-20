function newResults=processParameterObjects(this,modelName,runObj)



    newResults={};


    pObjInfoCollector=SimulinkFixedPoint.ParameterObjectInfoCollector(modelName);

    pObjInfoList=pObjInfoCollector.getParameterObjectInfo;

    if~isempty(pObjInfoList)

        newResults=this.createAndUpdateParameterResults(pObjInfoList,runObj,modelName);


        assocRecs=pObjInfoCollector.getAssocParamRequiringUpdate();
        for recIdx=1:length(assocRecs)

            this.setAssociatedParam(assocRecs{recIdx},runObj);
        end
    end
end




