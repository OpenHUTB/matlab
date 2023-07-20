function[isConstantMemoryParam,parameterDataObject]=getIsAutosarConstantMemoryObject(parameterDataObject)







    if~isempty(which('autosar.override.getIsAutosarConstantMemoryObject'))
        [isConstantMemoryParam,parameterDataObject]=autosar.override.getIsAutosarConstantMemoryObject(parameterDataObject);
        return
    end

    isConstantMemoryParam=false;

    if isa(parameterDataObject,'Simulink.Parameter')...
        ||isa(parameterDataObject,'Simulink.LookupTable')...
        ||isa(parameterDataObject,'Simulink.Breakpoint')
        if strcmp(parameterDataObject.CoderInfo.StorageClass,'ExportedGlobal')
            isConstantMemoryParam=true;
        elseif isa(parameterDataObject,'AUTOSAR4.Parameter')&&strcmp(parameterDataObject.CoderInfo.CustomStorageClass,'Global')
            isConstantMemoryParam=true;
        end
    end
end

function cscDefn=i_getCSCDefnRecurseThruRefs(package,cscName)
    cscDefn=processcsc('GetCSCDefn',package,cscName);
    if isa(cscDefn,'Simulink.CSCRefDefn')
        cscDefn=i_getCSCDefnRecurseThruRefs(cscDefn.RefPackageName,cscDefn.RefDefnName);
    end
end



