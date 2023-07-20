function onClickHandler(obj,callbackInfo)




    info=callbackInfo.EventData;
    client=info.getPerspectivesClient;
    editor=client.getEditor;
    studio=editor.getStudio;

    obj.togglePerspective(studio);


    client.closePerspectives;


