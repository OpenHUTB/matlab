classdef ProjectManager<evolutions.internal.datautils.AbstractInfoManager




    properties(Hidden,SetAccess=?matlab.mock.TestCase)




        MfModels mf.zero.Model



TopLevelProject



ProjectObserverCatalog
FileListenerCatalog
FileListenerData
    end

    methods
        function obj=ProjectManager(topLevelProject)
            obj=obj@evolutions.internal.datautils.AbstractInfoManager(...
            'evolutions.model.ProjectInfo');
            obj.FileListenerCatalog=dictionary(evolutions.model.ProjectInfo.empty(1,0),...
            evolutions.internal.FileChangeListener);
            obj.FileListenerData=dictionary("",struct);
            obj.MfModels=eval(sprintf('%s.empty(0,1)','mf.zero.Model'));
            obj.TopLevelProject=topLevelProject;
        end

        function setProjectObserver(obj)
            obj.ProjectObserverCatalog=evolutions.internal.ObserverCatalog;
        end

        addOpenProjects(obj)

        initialize(obj)

        projectInfo=getProjectInfoFromPath(obj,project)

        findReferencedProjectsRecursively(obj,project)

        pi=create(obj,project)

        reset(obj)

        save(obj)

        refreshEti(obj,eti)

        fileChangedCallback(this,src,event)

        updateProjectFileListener(obj,projectInfo)

    end

    methods(Static,Access=public)


        pm=get
        projectNameChanged(projectRoot)
        syncProjectFiles(projectRoot)
    end
end


