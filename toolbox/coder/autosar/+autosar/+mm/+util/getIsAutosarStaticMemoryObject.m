function[isStaticMemorySignal,signalDataObject]=getIsAutosarStaticMemoryObject(signalDataObject)







    if~isempty(which('autosar.override.getIsAutosarStaticMemoryObject'))
        [isStaticMemorySignal,signalDataObject]=autosar.override.getIsAutosarStaticMemoryObject(signalDataObject);
        return
    end

    isStaticMemorySignal=false;

    if isa(signalDataObject,'Simulink.Signal')
        if strcmp(signalDataObject.CoderInfo.StorageClass,'ExportedGlobal')
            isStaticMemorySignal=true;
        elseif isa(signalDataObject,'AUTOSAR4.Signal')&&strcmp(signalDataObject.CoderInfo.CustomStorageClass,'Global')
            isStaticMemorySignal=true;
        end
    end

end


function cscDefn=i_getCSCDefnRecurseThruRefs(package,cscName)
    cscDefn=processcsc('GetCSCDefn',package,cscName);
    if isa(cscDefn,'Simulink.CSCRefDefn')
        cscDefn=i_getCSCDefnRecurseThruRefs(cscDefn.RefPackageName,cscDefn.RefDefnName);
    end
end


