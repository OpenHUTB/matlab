function codeForName(cbinfo,action)




    studioApp=cbinfo.studio.App;
    if slfeature('SDPToolStrip')

        editor=studioApp.getActiveEditor;
        cgr=coder.internal.toolstrip.util.getCodeGenRoot(editor);
        action.text=get_param(cgr,'Name');
    else

        action.text=get_param(studioApp.topLevelDiagram.handle,'Name');
    end

