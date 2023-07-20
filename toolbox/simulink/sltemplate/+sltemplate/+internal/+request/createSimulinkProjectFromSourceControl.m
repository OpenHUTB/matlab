function createSimulinkProjectFromSourceControl(toolName)


    toolID='';
    if strcmp(toolName,'MWGitAdapter')
        toolID='com.mathworks.cmlink.implementations.git.GitRepository';
    else
        cmAdapterFactories=com.mathworks.cmlink.management.registration.SingletonCMAdapterFactoryList.getInstance().getFactories();
        for ii=1:cmAdapterFactories.size()
            cmAdapterFactory=cmAdapterFactories.get(ii-1);
            nullApplicationInteractor=com.mathworks.cmlink.util.interactor.NullApplicationInteractor;
            repository=cmAdapterFactory.getRepository(nullApplicationInteractor);
            if strcmp(cmAdapterFactory.getID(),toolName)
                toolID=repository.getID();
            end
        end
    end

    retriever=...
    com.mathworks.toolbox.slproject.project.GUI.canvas.actions.home.NewProjectFromSourceControl(toolID);

    retriever.actionPerformed([]);
end
