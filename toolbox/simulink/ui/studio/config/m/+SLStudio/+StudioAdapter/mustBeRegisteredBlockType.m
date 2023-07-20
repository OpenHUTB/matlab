function mustBeRegisteredBlockType(blockHandle,objectId)
    if blockHandle>0

        studioAdapterBlocktype=SA_M3I.StudioAdapterToolstripRegistryInterface.getStudioAdapterType(blockHandle);
        if(~SA_M3I.StudioAdapterToolstripRegistryInterface.isStudioAdapterTypeRegistered(studioAdapterBlocktype))

            error([studioAdapterBlocktype,' type is not registered in the StudioAdapterToolstripRegistry']);
        end
    else

        studioAdapterBlocktype=SA_M3I.StudioAdapterToolstripRegistryInterface.getStudioAdapterTypeForStateflow(objectId);
        if(~SA_M3I.StudioAdapterToolstripRegistryInterface.isStudioAdapterTypeRegistered(studioAdapterBlocktype))

            error([studioAdapterBlocktype,' type is not registered in the StudioAdapterToolstripRegistry']);
        end
    end
end