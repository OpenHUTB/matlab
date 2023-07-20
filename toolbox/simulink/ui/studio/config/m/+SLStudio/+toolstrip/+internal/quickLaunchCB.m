



function quickLaunchCB(userdata,cbinfo)
    editor=cbinfo.studio.App.getActiveEditor;


    if strcmp(userdata,'qab')

        canvas=editor.getCanvas;
        viewLocation=[canvas.ViewExtents(1)-200,-125];
        sceneLocation=canvas.viewPointToScenePoint(viewLocation);
        editor.sendMessageToToolsWithPoint('QuickLaunchActionsSearch',sceneLocation);
    else

        editor.sendMessageToTools('QuickLaunchActionsSearch');
    end
end
