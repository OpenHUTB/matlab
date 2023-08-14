function properties=getPropertyList(systemName,groups,varargin)




    p=inputParser;
    p.StructExpand=true;
    p.addParameter('SetDescription',false);
    p.addParameter('IncludeFacade',true);
    p.addParameter('IncludeSections',true);
    p.parse(varargin{:});
    inputs=p.Results;

    sysMetaClass=meta.class.fromName(systemName);
    properties=matlab.system.display.internal.Property.empty;
    for group=groups

        properties=[properties,...
        getGroupProperties(group,sysMetaClass,inputs)];%#ok<*AGROW>


        if inputs.IncludeSections&&group.IsSectionGroup
            for section=group.Sections
                properties=[properties,...
                getGroupProperties(section,sysMetaClass,inputs)];
            end
        end
    end
end

function properties=getGroupProperties(group,sysMetaClass,inputs)
    displayProperties=group.getDisplayProperties(sysMetaClass,'SetDescription',inputs.SetDescription);
    if inputs.IncludeFacade
        properties=displayProperties;
    else
        properties=matlab.system.display.internal.Property.empty;
        for property=displayProperties
            if~property.IsFacade
                properties(end+1)=property;
            end
        end
    end
end