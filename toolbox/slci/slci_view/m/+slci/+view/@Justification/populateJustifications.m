


function populateJustifications(obj,editor)

    src=slci.view.internal.getSource(editor);
    mdlH=src.modelH;

    dMgr=slci.view.Manager.getInstance.getData;
    reviewReader=dMgr.getReader(mdlH,'REVIEW');
    keyList=reviewReader.getObjectKeys();
    objList=reviewReader.getObjects(keyList);

    message.publish('/justification/clear',{});

    for i=1:numel(objList)
        jObj=objList{i};

        res.reviewer=jObj.getReviewer();
        res.timestamp=jObj.getTimestamp();
        res.summary=jObj.getSummary();
        res.description=jObj.getDescription();
        res.blockSID=jObj.getModelElement();
        res.blockName=Simulink.ID.getFullName(res.blockSID);
        cObj=jObj.getCodeObject();
        res.codeLines=cObj.toString();


        mdlName=src.modelName;
        jsonStr=jsonencode(res);
        message.publish(['/',obj.getChannel],{mdlName,jsonStr});
    end
