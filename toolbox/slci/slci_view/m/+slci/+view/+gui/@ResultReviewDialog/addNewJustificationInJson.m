


function addNewJustificationInJson(obj,data)
    try

        waitBar=waitbar(0,'Processing Justification');

        conf=slci.toolstrip.util.getConfiguration(obj.getStudio);
        fname=fullfile(conf.getReportFolder(),[conf.getModelName(),'_justification.json']);


        updateData=data.newJustification;



        modelManager=slci.view.ModelManager(fname);
        mfmodel=modelManager.getModel;
        if isequal(data.dataFor,'codeSliceGrid')
            updateData.codeLines=[data.CodeLines,'-',data.BlockSID];
            j=modelManager.getJustificationManager(data.CodeLines);
        else
            updateData.codeLines=[data.BlockSID,'-',data.CodeLines];
            j=modelManager.getJustificationManager(data.BlockSID);
        end

        waitbar(0.33,waitBar,'Processing Justification');
        checkCommentThread=j.getCommentThread();
        checkCommentThreadSize=checkCommentThread.Size;
        j.setFieldsFromFilterJSON(updateData);

        serializer=mf.zero.io.JSONSerializer;
        serializer.ShouldSkipDefaultValues=false;
        serializer.serializeToFile(mfmodel,fname);


        obj.setDeleteStatusFlag(false);
        waitbar(0.67,waitBar,'Processing Justification');

        if isequal(checkCommentThreadSize,0)

            dm=obj.getDataManager();
            if~isempty(dm)
                if isequal(data.dataFor,'codeSliceGrid')
                    slci.results.processCodeData(dm,conf);
                    obj.populateCodeSliceData();
                else
                    slci.results.processBlockData(dm,conf);
                    obj.populateBlockData();
                end
                obj.populateStatus();
                obj.sendData();
            end
        end
        close(waitBar);
    catch ME
        slci.internal.outputMessage(ME,'error');
    end
end
