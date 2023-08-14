function varargout=simulinkproject(varargin)












    narginchk(0,1);
    nargoutchk(0,1);

    outputRequested=(nargout>0);
    inputProvided=(nargin>0);

    if~outputRequested&&~inputProvided

        matlab.project.show();
        return
    end

    if~outputRequested&&inputProvided

        projectLocation=varargin{1};
        loadProject(projectLocation);
        matlab.project.show();
        return
    end

    if outputRequested&&~inputProvided

        try
            varargout{1}=slproject.getCurrentProject();
        catch exception
            import matlab.internal.project.util.exceptions.MatlabAPIMatlabException.throwAPIException;
            throwAPIException(exception);
        end
        return
    end

    if outputRequested&&inputProvided

        projectLocation=varargin{1};
        varargout{1}=loadProject(projectLocation);
        return
    end

end

function projectManager=loadProject(projectLocation)
    if isstring(projectLocation)
        projectLocation=char(projectLocation);
    end

    projectLocation=searchForProject(projectLocation);
    try
        projectManager=slproject.loadProject(projectLocation);
    catch exception
        import matlab.internal.project.util.exceptions.Prefs;
        if(Prefs.ShortenStacks)
            exception.throwAsCaller;
        else
            exception.rethrow;
        end
    end
end

function projectLocation=searchForProject(projectLocation)
    try
        canonicalProjectLocation=canonicalizeProjectLocation(projectLocation);
        if isempty(canonicalProjectLocation)
            return
        end
        if isfolder(canonicalProjectLocation)
            canonicalProjectLocation=fullfile(canonicalProjectLocation,'DUMMY');
        end

        [isUnderProjectRoot,projectRoot]=...
        slproject.isUnderProjectRoot(canonicalProjectLocation);
        if isUnderProjectRoot
            projectLocation=projectRoot;
        end
    catch exception %#ok<NASGU>





    end
end

function canonicalLocation=canonicalizeProjectLocation(projectLocation)
    candidate=getCanonicalPath(projectLocation);
    canonicalLocation=canonicalFolderOrFile(candidate);
    if~isempty(canonicalLocation)
        return
    end

    [canonicalParentPath,canonicalFileName]=getCanonicalFileParts(candidate);
    if isempty(canonicalParentPath)
        canonicalLocation='';
        return
    end

    canonicalLocation=caseInsensitiveFileSystemMatch(canonicalParentPath,canonicalFileName);
end

function canonicalLocation=caseInsensitiveFileSystemMatch(parentPath,fileName)
    locationContents=dir(parentPath);
    try
        candidateName=validatestring(fileName,{locationContents.name});
        canonicalLocation=fullfile(parentPath,candidateName);
    catch exception
        if strcmp(exception.identifier,'MATLAB:unrecognizedStringChoice')||...
            strcmp(exception.identifier,'MATLAB:ambiguousStringChoice')
            canonicalLocation='';
            return
        end
    end
end

function canonicalPath=getCanonicalPath(input)
    canonical=matlab.internal.project.util.PathUtils.resolveFileAgainstFileSystem(fullfile(input,'DUMMY'),false);
    canonicalPath=fileparts(canonical);
end

function[canonicalFilePath,canonicalFileName]=getCanonicalFileParts(childPath)
    [parentPath,canonicalFileName,~]=fileparts(childPath);
    canonicalFilePath=canonicalFolderOrFile(parentPath);
    if~exist(canonicalFilePath,'dir')
        canonicalFilePath=char.empty();
    end
end

function canonicalLocation=canonicalFolderOrFile(candidate)
    canonicalLocation=matlab.internal.project.util.PathUtils.resolveFileAgainstFileSystem(candidate,true);
end

