function update_visibility(bd)

    mdlName=get_param(bd,'Name');
    mdlHandle=get_param(bd,'Handle');
    editors=GLUE2.Util.findAllEditors(mdlName);

    if~any(arrayfun(@(x)(x.isVisible),editors))

        sltp.internal.ScheduleEditorManager.hideEditor(mdlHandle);
    end

end