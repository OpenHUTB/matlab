function open(obj,studio)






    obj.init();

    modelH=studio.App.blockDiagramHandle;
    editor=studio.App.getActiveEditor;


    editor.closeNotificationByMsgID('CoderAppClosedByTargetChange');


    obj.addInFlag(modelH,studio);


    for i=1:length(obj.tasks)
        task=obj.tasks{i};

        if obj.debugMode
            tic;
        end

        result=task.turnOnByCodePerspective(editor);

        if obj.debugMode
            x=toc;
            disp(['turn on ',task.ID,': ',num2str(x)]);
        end

        if~result

            for j=1:i-1
                task=obj.tasks{j};
                task.turnOff(editor);
            end

            obj.removeFlag(modelH,studio);
            return;
        end
    end



    GLUE2.invalidateAllPerspectives;
    simulinkcoder.internal.util.CanvasElementSelection.refreshSignalBadges(modelH);



