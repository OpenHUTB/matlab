function dialogCallback(obj,tag,value)



    src=simulinkcoder.internal.util.getSource(obj.studio);

    cp=simulinkcoder.internal.CodePerspective.getInstance();
    tasks=cp.tasks;
    task=[];
    for i=1:length(tasks)
        if strcmp(tasks{i}.ID,tag)
            task=tasks{i};
        end
    end

    if isempty(task)
        return;
    end

    switch tag
    case{'CodeMapping','ModelData','PropertyInspector'}

        task.turnOn(src.editor);

    case{'EditTimeChecking','StorageClassOnSignals'}

        if value
            task.turnOn(src.editor);
        else
            task.turnOff(src.editor);
        end

    otherwise

    end