function bSuccess=ProjectObserver(projectRoot,action)








    import com.mathworks.toolbox.slproject.project.extensions.listeners.MlProjectLabelListener;

    mlock;


    persistent LabelChangedListener;
    persistent AbsoluteRootFolder;


    projectRoot=fullfile(projectRoot);

    bSuccess=false;
    switch(action)

    case 'activate'


        jPrjMgr=getProjectManager(projectRoot);



        if isempty(jPrjMgr)
            return;
        end

        AbsoluteRootFolder=projectRoot;

        LabelChangedListener=MlProjectLabelListener(...
        'alm.internal.project.onLabelChanged',projectRoot);
        jPrjMgr.addListener(LabelChangedListener);

        bSuccess=true;

    case 'deactivate'





        jPrjMgr=getProjectManager(projectRoot);
        if~isempty(jPrjMgr)
            jPrjMgr.removeListener(LabelChangedListener);
        end

        AbsoluteRootFolder='';
        LabelChangedListener=[];

        bSuccess=true;

    otherwise
        error(['Unkown action ',action,'.']);
    end


end


function jPrjMgr=getProjectManager(projectRoot)

    import com.mathworks.toolbox.slproject.project.controlset.store.implementations.SingletonProjectStore;

    jProjectStore=SingletonProjectStore.getInstance();
    jPrjs=jProjectStore.getTopLevelProjects();


    assert(jPrjs.size()<=1,"Expected that there is exactly one or no"+...
    "top-level project in the Java implementation");

    if jPrjs.size()==0
        jPrjMgr=[];
        return;
    end

    jPrj=jPrjs.iterator().next();

    if string(jPrj.getProjectRoot())~=projectRoot
        jPrjMgr=[];
        return;
    end

    jPrjCtrlSet=jPrj.getProjectControlSet();
    jPrjMgr=jPrjCtrlSet.getProjectManager();

end
