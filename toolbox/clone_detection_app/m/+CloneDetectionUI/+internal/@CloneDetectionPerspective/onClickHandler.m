function onClickHandler(obj,cbinfo)



    info=cbinfo.EventData;
    client=info.getPerspectivesClient;
    editor=client.getEditor;

    obj.togglePerspective(editor);


    client.closePerspectives;
