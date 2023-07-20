


function updateJustificationJson(obj,data)
    try

        waitBar=waitbar(0,'Processing Justification');

        conf=slci.toolstrip.util.getConfiguration(obj.getStudio);
        fname=fullfile(conf.getReportFolder(),[conf.getModelName(),'_justification.json']);


        modelManager=slci.view.ModelManager(fname);
        mfmodel=modelManager.getModel;

        if isequal(data.dataFor,'codeSliceGrid')
            j=modelManager.getJustificationManager(data.CodeLines);
        else
            j=modelManager.getJustificationManager(data.BlockSID);
        end
        waitbar(0.33,waitBar,'Processing Justification');
        filterJSON=data.JustificationLog;
        j.setFieldsFromFilterJSONEdit(filterJSON);
        if isequal(data.dataFor,'codeSliceGrid')
            j.setCodeLines([data.CodeLines,'-',data.BlockSID]);
        else
            j.setCodeLines([data.BlockSID,'-',data.CodeLines]);
        end
        waitbar(0.67,waitBar,'Processing Justification');
        serializer=mf.zero.io.JSONSerializer;
        serializer.ShouldSkipDefaultValues=false;
        serializer.serializeToFile(mfmodel,fname);
        close(waitBar);

    catch ME
        slci.internal.outputMessage(ME,'error');
    end
end
