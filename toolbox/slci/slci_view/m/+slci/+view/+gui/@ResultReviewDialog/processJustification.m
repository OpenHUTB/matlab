function processJustification(msg,studio)




    try

        conf=slci.toolstrip.util.getConfiguration(studio);
        fname=fullfile(conf.getReportFolder(),[conf.getModelName(),'_justification.json']);


        data=msg.data;
        rowObj=data.rowObj;
        msgFilter=data.filter;


        modelManager=slci.view.ModelManager(fname);
        mfmodel=modelManager.getModel;

        j=modelManager.getJustificationManager(rowObj.sid);

        j.setFieldsFromFilterJSON(msgFilter);

        serializer=mf.zero.io.JSONSerializer;
        serializer.ShouldSkipDefaultValues=false;

        serializer.serializeToFile(mfmodel,fname);

    catch ME
        slci.internal.outputMessage(ME,'error');
    end
end
