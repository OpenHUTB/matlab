function setNoCodeGen(cbinfo)

    if~cbinfo.EventData
        return;
    end

    studio=cbinfo.studio;
    refresher=coder.internal.toolstrip.util.Refresher(studio);%#ok<NASGU>
    mdl=cbinfo.editorModel.Handle;

    if cbinfo.EventData
        set_param(mdl,'CodeGenBehavior','None');
        cp=simulinkcoder.internal.CodePerspective.getInstance;
        cv=cp.getTask('CodeReport');
        if~isempty(cv)
            cv.turnOff(studio);
        end
    end
