


function deleteAllJustificationComments(obj,data)
    try
        answer=questdlg(...
        DAStudio.message('Slci:slcireview:JustificationConfirmDeleteDialogWarning'),...
        DAStudio.message('Slci:slcireview:JustificationConfirmDeleteDialogTitle'),...
        DAStudio.message('Slci:slcireview:JustificationConfirmDeleteDialogYes'),...
        DAStudio.message('Slci:slcireview:JustificationConfirmDeleteDialogNo'),...
        DAStudio.message('Slci:slcireview:JustificationConfirmDeleteDialogYes'));

        switch answer
        case 'Yes'

            conf=slci.toolstrip.util.getConfiguration(obj.getStudio);
            fname=fullfile(conf.getReportFolder(),[conf.getModelName()...
            ,'_justification.json']);


            modelManager=slci.view.ModelManager(fname);
            mfmodel=modelManager.getModel;


            if strcmpi(data.dataFor,'codeSliceGrid')
                modelManager.deleteJustification(data.codelines);
            else
                modelManager.deleteJustification(data.sid);
            end

            serializer=mf.zero.io.JSONSerializer;
            serializer.ShouldSkipDefaultValues=false;
            serializer.serializeToFile(mfmodel,fname);


            if strcmpi(data.dataFor,'codeSliceGrid')
                uiJsonSid='';
                uiJsonCodeLines=data.codelines;
            else
                uiJsonSid=data.sid;
                uiJsonCodeLines='';
            end

            uiJsonCommentThreadTable=[];
            finalJson=struct('BlockSID',uiJsonSid,'loggedInUser',...
            obj.getUsername,'CodeLines',uiJsonCodeLines,...
            'JustificationLog',{uiJsonCommentThreadTable},'dataFor',...
            data.dataFor,'newJustification','',...
            'MsgForJustificationDialog',obj.getMsgForJustificationDialog);
            sendJson=jsonencode(finalJson);
            obj.setJsonDataAfterDeletes(sendJson);



            obj.setDeleteStatusFlag(true);


            dm=obj.getDataManager();
            if~isempty(dm)
                if strcmpi(data.dataFor,'codeSliceGrid')
                    slci.results.processCodeData(dm,conf);
                    obj.populateCodeSliceData();
                else
                    slci.results.processBlockData(dm,conf);
                    obj.populateBlockData();
                end
                obj.populateStatus();
                obj.sendData();
            end
        case 'No'

        end
    catch ME
        slci.internal.outputMessage(ME,'error');
    end
end
