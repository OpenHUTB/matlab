




function writeModelToJSON(obj)
    obj.cacheData(false);


    serializer=mf.zero.io.JSONSerializer;


    metaModel=obj.mBDMgr.getMetaModel();


    result=serializer.serializeToString(metaModel);


    outDir=fullfile(matlabroot,'test','toolbox','simulink','variants','configurationAnalysis','configAnalysisUI','mockmodel');

    modelname=obj.ModelName;
    outFilePath=fullfile(outDir,modelname);
    outFilePath=strcat(outFilePath,'_mockmodel.json');


    outFileID=fopen(outFilePath,'w');
    fprintf(outFileID,'%s',result);
    fclose(outFileID);

end


