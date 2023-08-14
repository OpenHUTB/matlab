



function getJustificationForSid(obj,msg)
    conf=slci.toolstrip.util.getConfiguration(obj.getStudio);
    fname=fullfile(conf.getReportFolder(),[conf.getModelName(),'_justification.json']);
    modelManager=slci.view.ModelManager(fname);
    j=modelManager.getJustificationManager(msg.sid);


    uiJsonSid=j.getSID();
    uiJsonCodeLines=j.getCodeLines();
    if~isempty(uiJsonCodeLines)
        spiltCodeLines=split(uiJsonCodeLines,"-");
        uiJsonCodeLines=spiltCodeLines(2);
    end
    uiJsonCommentThread=j.getCommentThread();

    finalJson=customJSONHelper(obj,uiJsonSid,uiJsonCodeLines,...
    msg,uiJsonCommentThread);
    sendJson=jsonencode(finalJson);


    vm=slci.view.Manager.getInstance;
    vw=vm.getView(obj.getStudio);
    ds=vw.getJustification();
    ds.refresh(obj.getResultReviewID(),sendJson);

end
