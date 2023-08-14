function project=loadProject(projectLocation)












    validateattributes(projectLocation,{'char','string'},{'nonempty'},'','projectLocation');

    if isstring(projectLocation)
        projectLocation=char(projectLocation);
    end

    import matlab.internal.project.util.PathUtils;
    import matlab.internal.project.util.assertProjectNotShuttingDown;
    import matlab.internal.project.util.assertProjectNotStartingUp;



    assertProjectNotShuttingDown();
    assertProjectNotStartingUp();

    if matlab.internal.project.util.useWebFrontEnd
        if exist(projectLocation,'file')
            [parentFolder,~,ext]=fileparts(projectLocation);
            if ".prj"==ext
                projectLocation=parentFolder;
            end
        end
        project=matlab.internal.project.api.loadProject(projectLocation);
        return;
    end


    error(javachk('jvm','MATLAB Projects'));

    resolvedJFile=PathUtils.getJavaFileForProjectLoadFromMATLABString(projectLocation);

    iCloseCurrentProjectIfRequired();
    iLoadProject(resolvedJFile);

    project=matlab.project.currentProject();

end

function iCloseCurrentProjectIfRequired()





    canvasFactory=com.mathworks.toolbox.slproject.project.GUI.canvas.factory.ProjectCanvasFactorySingleton.getInstance();
    if~canvasFactory.isMultiInstance()
        proj=matlab.project.currentProject;
        if~isempty(proj)
            proj.close();
        end
    end

end

function projectContainer=iGetProjectStore()
    projectContainer=com.mathworks.toolbox.slproject.project.controlset.store.implementations.SingletonProjectStore.getInstance();
end

function iLoadProject(file)

    import matlab.internal.project.util.processJavaCall;
    import matlab.internal.project.util.exceptions.Prefs;

    projectContainer=iGetProjectStore();
    try
        projectContainer.addTopLevelProject(file);
    catch exception

        if(Prefs.ShortenStacks)
            matlabException=iConvertLoadFailException(exception);
            matlabException.throwAsCaller;
        else
            exception.rethrow;
        end
    end
end

function matlabException=iConvertLoadFailException(exception)

    if(strcmpi(exception.identifier,'MATLAB:Java:GenericException'))

        javaException=exception.ExceptionObject;
        matlabException=MException('MATLAB:project:api:LoadFail','%s',...
        char(javaException.getMessage()));
    else
        matlabException=exception;
    end

end
