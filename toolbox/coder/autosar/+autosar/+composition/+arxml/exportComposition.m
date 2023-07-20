function exportComposition(modelName,varargin)



































    autosar.api.Utils.autosarlicensed(true);


    modelName=convertStringsToChars(modelName);
    for ii=1:length(varargin)
        if isstring(varargin{ii})
            varargin{ii}=convertStringsToChars(varargin{ii});
        end
    end


    argParser=inputParser;
    argParser.addRequired('ModelName',@ischar);
    argParser.addParameter('CompositionQualifiedName','',@ischar);
    argParser.addParameter('ExportServicePorts',false,@islogical);

    argParser.parse(modelName,varargin{:});
    modelName=argParser.Results.ModelName;
    compositionQualifiedName=argParser.Results.CompositionQualifiedName;
    exportServicePorts=argParser.Results.ExportServicePorts;


    [~,modelName]=fileparts(modelName);


    systems=find_system('type','block_diagram','name',modelName);
    if isempty(systems)
        DAStudio.error('RTW:autosar:mdlNotLoaded',modelName);
    end


    isCompliant=strcmp(get_param(modelName,'AutosarCompliant'),'on');
    if~isCompliant
        DAStudio.error('RTW:autosar:nonAutosarCompliant');
    end


    autosar.api.Utils.checkQualifiedName(...
    modelName,compositionQualifiedName,'absPathShortName');


    autosar.composition.api.create(modelName,'CompositionQualifiedName',...
    compositionQualifiedName,...
    'ExportServicePorts',exportServicePorts);


    codegendir=Simulink.fileGenControl('get','CodeGenFolder');
    arxmlfilename=fullfile(codegendir,[modelName,'.arxml']);
    includeComponents=false;
    autosar.composition.arxml.writeCompositionFile(modelName,arxmlfilename,includeComponents);


