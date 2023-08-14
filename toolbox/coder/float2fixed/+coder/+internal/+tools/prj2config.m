


function varargout=prj2config(projectFile)

    varargout{:}=loadProjectFile(which(projectFile));
end

function res=isValidPrjFile(fileName)
    res=false;
    [~,~,ext]=fileparts(fileName);
    if strmp(ext,'prj')
        res=true;
    end
end


function varargout=loadProjectFile(projectFile)
    [CC.options.ProjectRoot,~,~]=fileparts(projectFile);

    com.mathworks.project.impl.plugin.PluginManager.allowMatlabThreadUse();

    try
        javaProject=com.mathworks.project.impl.model.ProjectManager.load(...
        java.io.File(projectFile),true,true);
    catch me %#ok<NASGU>
        if~exist(projectFile,'file')
            error(message('Coder:common:ProjectFileNotFound',projectFile));
        else
            error(message('Coder:common:ProjectFileInvalid',projectFile));
        end
    end

    javaConfig=javaProject.getConfiguration();

    if isHDLCoderProject(javaConfig);




        xDoc=xmlread(projectFile);
        varargout{:}=coder.internal.tools.prj2cfg.hdlprj2cfg(javaConfig,xDoc);
    else
        disp('Project file is not a hdl project file, currently only hdl projects are supported');
    end
end


function isHDLPrj=isHDLCoderProject(javaConfig)
    isHDLPrj=[];

    key=char(javaConfig.getTarget().getKey());
    switch lower(key)
    case 'target.matlab.coder'
        isHDLPrj=false;
    case 'target.matlab.ecoder'
        if coderprivate.hasEmbeddedCoder()
            isHDLPrj=false;
        end
    case 'target.matlab.hdlcoder'
        isHDLPrj=true;
    end

    if isempty(isHDLPrj)
        emlcprivate('ccdiagnosticid',Coder:configSet:UnrecognizedProject',...
        char(javaConfig.getProject().getFile().getAbsolutePath()));
    end
end