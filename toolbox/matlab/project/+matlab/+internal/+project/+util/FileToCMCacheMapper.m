


classdef FileToCMCacheMapper<handle

    properties(Dependent=true,GetAccess=public,SetAccess=private)
        UsingSourceControl;
        CanCheckOut;
        IsCheckedOut;
        Status;
        SourceControlCache;
    end

    properties(Dependent=true,GetAccess=private,SetAccess=private)
        ProjectManager;
    end

    properties(GetAccess=private,SetAccess=private)

        FileToProjectMapper=[];
        cachedValuesPopulated=false;

        cUsingSourceControl=[];
        cCanCheckOut=[];
        cStatus=[];
        cIsCheckedOut=[];
        cSourceControlCache=[];
        cProjectManager=[];
        cApplicationInteractor=[];
    end

    methods

        function value=get.UsingSourceControl(obj)
            obj.populateCachedValues();
            value=obj.cUsingSourceControl;
        end
        function value=get.CanCheckOut(obj)
            obj.populateCachedValues();
            value=obj.cCanCheckOut;
        end

        function value=get.IsCheckedOut(obj)
            obj.populateCachedValues();
            value=obj.cIsCheckedOut;
        end
        function value=get.Status(obj)
            obj.populateCachedValues();
            value=obj.cStatus;
        end
        function value=get.SourceControlCache(obj)
            obj.populateCachedValues();
            value=obj.cSourceControlCache;
        end
        function value=get.ProjectManager(obj)
            obj.populateCachedValues();
            value=obj.cProjectManager;
        end
    end

    methods(Access=private)

        function populateCachedValues(obj)
            import com.mathworks.toolbox.slproject.project.matlab.api.MatlabAPIFacadeFactory;
            if(obj.cachedValuesPopulated)
                return;
            end
            obj.cachedValuesPopulated=true;


            projectRoot=obj.FileToProjectMapper.ProjectRoot;
            try
                projectControlSet=MatlabAPIFacadeFactory.getMatchingControlSet(java.io.File(projectRoot));
            catch ME
                return;
            end

            obj.cProjectManager=projectControlSet.getProjectManager();
            obj.cApplicationInteractor=projectControlSet.getInteractor();
            obj.cSourceControlCache=projectControlSet.getProjectCMStatusCache();
            obj.cUsingSourceControl=obj.SourceControlCache.usingCM();
            adapter=obj.SourceControlCache.getAdapter();
            if isempty(adapter)
                return;
            end
            fileState=obj.getFileState();
            obj.cStatus=fileState.getLocalStatus;
            obj.cCanCheckOut=adapter.isFeatureSupported(com.mathworks.cmlink.api.AdapterSupportedFeature.LOCK);
            obj.cIsCheckedOut=obj.CanCheckOut&&fileState.hasLock();
        end
    end


    methods(Access=public)

        function obj=FileToCMCacheMapper(fileToProjectMapper)
            obj.FileToProjectMapper=fileToProjectMapper;
        end

        function checkout(obj)
            import com.mathworks.toolbox.slproject.project.matlab.util.ProjectFromMatlabCmUiSupport;

            jFile=obj.fileAsJavaFile();
            adapter=obj.SourceControlCache.getAdapter();
            ProjectFromMatlabCmUiSupport.getLock(jFile,adapter);
        end

        function uncheckout(obj)
            import com.mathworks.toolbox.slproject.project.matlab.util.ProjectFromMatlabCmUiSupport;
            jFile=obj.fileAsJavaFile();
            adapter=obj.SourceControlCache.getAdapter();
            if ProjectFromMatlabCmUiSupport.uncheckout(jFile,adapter)
                file=obj.FileToProjectMapper.File;
                close_system(file)
                open_system(file);
            end
        end

        function compareToAncestor(obj)
            import com.mathworks.toolbox.slproject.project.matlab.util.ProjectFromMatlabCmUiSupport;

            jFile=obj.fileAsJavaFile();
            adapter=obj.SourceControlCache.getAdapter();
            ProjectFromMatlabCmUiSupport.compareToAncestor(jFile,adapter);
        end

        function compareToRevision(obj)
            import com.mathworks.toolbox.slproject.project.matlab.util.ProjectFromMatlabCmUiSupport;
            import com.mathworks.cmlink.util.behaviour.BasicCMActionManager;

            adapter=obj.SourceControlCache.getAdapter();
            ProjectFromMatlabCmUiSupport.showCompareToRevisionDialog(...
            obj.fileAsList(),...
            obj.cApplicationInteractor,...
            adapter);
        end

    end


    methods(Access=private)
        function fileState=getFileState(obj)
            fileState=obj.SourceControlCache.getFileState(obj.fileAsJavaFile());
        end

        function file=fileAsJavaFile(obj)
            file=obj.FileToProjectMapper.File;
            file=java.io.File(file);
        end

        function files=fileAsList(obj)
            files=java.util.Collections.singleton(obj.fileAsJavaFile());
        end

    end


end