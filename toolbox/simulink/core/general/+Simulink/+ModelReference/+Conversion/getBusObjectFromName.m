function busObj=getBusObjectFromName(busName,okToError,dataAccessor)
    busObj=sl('slbus_get_object_from_name_withDataAccessor',busName,okToError,dataAccessor);
end
