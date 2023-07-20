function deleteModelMapping(modelH,varargin)






    bdType=get_param(modelH,'BlockDiagramType');
    if isequal(bdType,'subsystem')

        DAStudio.error('RTW:autosar:SubsystemReferenceModel',get_param(modelH,'Name'));
    elseif isequal(bdType,'library')

        DAStudio.error('RTW:autosar:LibraryModel',get_param(modelH,'Name'));
    end

    p=inputParser;


    addParameter(p,'MappingType','',@ischar);
    parse(p,varargin{:});

    if~isempty(p.Results.MappingType)
        mappingType=p.Results.MappingType;
        mapping=Simulink.CodeMapping.get(modelH,mappingType);
    else
        mapping=Simulink.CodeMapping.getCurrentMapping(modelH);
    end

    if~isempty(mapping)
        mapping.unmap();
        mmgr=get_param(modelH,'MappingManager');
        mmgr.deleteMapping(mapping);
    end

end