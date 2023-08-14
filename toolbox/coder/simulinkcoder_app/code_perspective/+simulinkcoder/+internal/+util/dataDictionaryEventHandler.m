function dataDictionaryEventHandler(ddFile,eventLabel)


    cp=simulinkcoder.internal.CodePerspective.getInstance;
    eventData=simulinkcoder.internal.util.DataDictionaryEventData(ddFile,eventLabel);
    cp.notify('CodePerspectiveChange',eventData);

