function close(obj,studio)





    obj.init();

    modelH=studio.App.blockDiagramHandle;
    editor=studio.App.getActiveEditor;

    flag=obj.getFlag(modelH,studio);
    if~isempty(flag)
        for i=1:length(obj.tasks)
            task=obj.tasks{i};

            if obj.debugMode
                tic;
            end

            task.turnOffByCodePerspective(editor);

            if obj.debugMode
                x=toc;
                disp(['turn off ',task.ID,': ',num2str(x)]);
            end
        end
    end


    obj.removeFlag(modelH,studio);



    GLUE2.invalidateAllPerspectives;
    simulinkcoder.internal.util.CanvasElementSelection.refreshSignalBadges(modelH);



