function registerGlobalProjectListeners()





    import com.mathworks.toolbox.slproject.project.controlset.store.matlab.MatlabProjectAddedListener;
    import com.mathworks.toolbox.slproject.project.controlset.store.matlab.MatlabProjectRemovedListener;
    import com.mathworks.toolbox.slproject.project.controlset.store.implementations.SingletonProjectStore;

    mlock;
    persistent closedProjectListener;
    persistent openedProjectListener;

    if isempty(closedProjectListener)
        projectStore=SingletonProjectStore.getInstance();

        closedProjectListener=MatlabProjectRemovedListener(...
        'alm.internal.project.onProjectClosed',{});
        projectStore.addListener(closedProjectListener);

        openedProjectListener=MatlabProjectAddedListener(...
        'alm.internal.project.onProjectOpened',{});
        projectStore.addListener(openedProjectListener);
    end

end
