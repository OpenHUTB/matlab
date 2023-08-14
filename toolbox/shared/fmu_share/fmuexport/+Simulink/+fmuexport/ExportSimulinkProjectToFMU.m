function ExportSimulinkProjectToFMU(projectManager,mainModelName,varargin)








































    narginchk(2,14);

    for i=1:2:length(varargin)
        if i+1>length(varargin)
            throw(MSLException([],message('FMUShare:FMU:UnpairedArguments',varargin{i})));
        end
        switch varargin{i}
        case '-description'
        case '-author'
        case '-copyright'
        case '-license'
        case '-fmuname'
        case '-fmuicon'
        otherwise
            throw(MSLException([],message('FMUShare:FMU:UnrecognizedArguments',varargin{i})));
        end
    end


    if~isa(projectManager,'slproject.ProjectManager')
        throw(MSLException([],message('FMUShare:FMU:ProjectInvalidArgument1')));
    end
    if~projectManager.isLoaded
        throw(MSLException([],message('FMUShare:FMU:ProjectNotLoaded',projectManager.Name)));
    end


    if isempty(projectManager.findFile(mainModelName))
        throw(MSLException([],message('FMUShare:FMU:ProjectInvalidArgument2')));
    end
    [~,modelName,~]=fileparts(mainModelName);
    if exist(modelName,'file')~=4||length(projectManager.findFile(mainModelName))~=1||...
        strcmp(which(modelName),projectManager.findFile(mainModelName).Path)~=1
        throw(MSLException([],message('FMUShare:FMU:ProjectInvalidArgument2')));
    end
    slprojectName=projectManager.Name;


    try
        Simulink.fmuexport.internal.shareSimulinkProjectAsFMU(...
        mainModelName,slprojectName,varargin{:});
    catch ex
        throwAsCaller(ex);
    end
end
