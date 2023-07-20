function open_partition(mdl,tasks)




    handle=get_param(mdl,'Handle');
    editor=sltp.internal.ScheduleEditorManager.getEditor(handle);
    editor.show();

    if~iscellstr(tasks)
        tasks={tasks};
    end


    ge=sltp.GraphEditor(handle);
    ge.setTaskHilite(tasks,true);

end
