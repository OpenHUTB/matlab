


function reverseTransitionCB(callbackInfo)
    selection=callbackInfo.selection;
    if selection.size==1
        transitionM3I=selection.at(1);
        editor=callbackInfo.studio.App.getActiveEditor;
        StateflowDI.Util.reverseTransition(editor,transitionM3I);
    end
end
