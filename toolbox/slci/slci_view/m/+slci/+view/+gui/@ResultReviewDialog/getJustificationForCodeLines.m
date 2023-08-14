



function getJustificationForCodeLines(obj,msg)
    conf=slci.toolstrip.util.getConfiguration(obj.getStudio);
    fname=fullfile(conf.getReportFolder(),[conf.getModelName(),'_justification.json']);
    modelManager=slci.view.ModelManager(fname);
    j=modelManager.getJustificationManager(msg.codelines);




    uiJsonSid=j.getCodeLines();
    if~isempty(uiJsonSid)
        spiltSid=split(uiJsonSid,"-");
        uiJsonSid=spiltSid(2);
    end
    uiJsonCodeLines=j.getSID();
    uiJsonCommentThread=j.getCommentThread();

    finalJson=customJSONHelper(obj,uiJsonSid,uiJsonCodeLines,...
    msg,uiJsonCommentThread);
    sendJson=jsonencode(finalJson);


    vm=slci.view.Manager.getInstance;
    vw=vm.getView(obj.getStudio);
    ds=vw.getJustification();
    ds.refresh(obj.getResultReviewID(),sendJson);

end
