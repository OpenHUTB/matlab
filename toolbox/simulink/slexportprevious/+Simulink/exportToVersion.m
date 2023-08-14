function exported_filename=exportToVersion(entity_to_export,target_filename,...
    version,varargin)











































    if isa(entity_to_export,'matlab.internal.project.api.Project')
        error(message('SimulinkProject:util:exportNewAPINotSupported'))
    end

    if isa(entity_to_export,'matlab.project.Project')
        exported_filename=slexportprevious.internal.exportProjectToVersion(...
        entity_to_export,target_filename,version,varargin{:});
    else
        exported_filename=slexportprevious.internal.exportToVersion(entity_to_export,...
        target_filename,version,varargin{:});
    end

