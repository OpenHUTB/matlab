function create(modelName,varargin)






    argParser=inputParser;
    argParser.addRequired('ModelName',@ischar);
    argParser.addParameter('CompositionQualifiedName','',@ischar);
    argParser.addParameter('ExportServicePorts',false,@islogical);

    argParser.parse(modelName,varargin{:});
    compositionQualifiedName=argParser.Results.CompositionQualifiedName;
    exportServicePorts=argParser.Results.ExportServicePorts;


    assert(~autosar.api.Utils.isMappedToComponent(modelName),...
    '%s is mapped to an AUTOSAR software component. Unmap first.',modelName);


    autosar_ui_close(modelName);


    validateCompositionModel=true;
    compositionBuilder=autosar.composition.sl2mm.ModelBuilder(modelName,...
    compositionQualifiedName,exportServicePorts,validateCompositionModel);
    compositionBuilder.build();


