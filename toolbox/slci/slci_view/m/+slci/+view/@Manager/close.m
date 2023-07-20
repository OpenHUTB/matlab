


function close(obj,studio)

    editor=studio.App.getActiveEditor;

    obj.turnOffView(editor);


    slci.toolstrip.util.recoverEditTimeChecks(studio);