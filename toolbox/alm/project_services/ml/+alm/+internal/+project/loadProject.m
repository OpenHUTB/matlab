


function loadProject(folder,bForceShowUI)

    prj=matlab.project.rootProject();


    if isempty(prj)||~strcmp(prj.RootFolder,folder)


        if~isProjectUIOpen()&&~bForceShowUI
            import com.mathworks.toolbox.slproject.project.controlset.store.implementations.SingletonProjectStore;

            prevValue=SingletonProjectStore.enableUIResponse(bForceShowUI);
            cleanup=onCleanup(@()SingletonProjectStore.enableUIResponse(prevValue));
        end

        openProject(folder);
    end
end

function isOpen=isProjectUIOpen()
    isOpen=~isempty(com.mathworks.toolbox.slproject.project.GUI.canvas.SingletonProjectCanvasController.getInstance().getChild());
end
