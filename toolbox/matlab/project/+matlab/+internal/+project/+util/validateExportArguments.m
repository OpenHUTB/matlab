function results=validateExportArguments(proj,archivePath,varargin)




    p=inputParser;
    p.addRequired('proj',@(x)validateattributes(x,{'matlab.internal.project.api.Project','matlab.project.Project'},{'size',[1,1]},'','project'));
    p.addRequired('file',@(x)validateattributes(x,{'char','string'},{'nonempty'},'','file'));

    p.addOptional('archiveReferences',true,@(x)validateattributes(x,{'logical'},{},'','archiveReferences'));

    p.addOptional('definitionType',[],@(x)validateattributes(x,{'matlab.project.DefinitionFiles'},{'nonempty'},'','definitionType'));
    p.addOptional('version',[],@(x)validateattributes(x,{'double'},{'size',[1,1]},'','version'));
    p.addOptional('definitionFolder','',@(x)validateattributes(x,{'char','string'},{'nonempty'},'','definitionFolder'));
    p.addOptional('exportUUIDMetaDataFile',true,@(x)validateattributes(x,{'logical'},{},'','exportUUIDMetaDataFile'));
    p.addOptional('specifiedFilesOnly',{},@(x)validateattributes(x,{'cell'},{},'specifiedFilesOnly'));
    p.addOptional('preventExportWithMissingFiles',true,@(x)validateattributes(x,{'logical'},{},'','preventExportWithMissingFiles'));
    p.parse(proj,archivePath,varargin{:});

    results=p.Results;
end

