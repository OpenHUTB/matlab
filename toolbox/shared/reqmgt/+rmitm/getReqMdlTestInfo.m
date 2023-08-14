function reqInfo=getReqMdlTestInfo(modelList,testFilePath)



    obj=rmitm.ReqTestModelDataProvider();
    obj.modelList=modelList;
    obj.testFilePath=testFilePath;
    obj.populateData();
    reqInfo=obj.getInfoStructure();
end