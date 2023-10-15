function status = unregisterAdapterByName( adapterDisplayName )

arguments
    adapterDisplayName( 1, 1 )string
end

classList = sl.data.adapter.AdapterManagerV2.getMCOSAdapterClasses;
adptCount = numel( classList );
found = false;
for i = 1:adptCount
    adpt = eval( classList{ i } );
    if strcmp( adapterDisplayName, adpt.getAdapterName )
        found = true;
        break ;
    end
end

if found
    try
        status = sl.data.adapter.AdapterManagerV2.unregisterAdapterByName( adapterDisplayName );
    catch ex
        status = false;
        warning( ex.identifier, '%s', ex.message );
    end
else
    status = false;
    warning( 'sl_data_adapter:messages:UnregisterAdapterDisplaynameNotFound', DAStudio.message( 'sl_data_adapter:messages:UnregisterAdapterDisplaynameNotFound', adapterDisplayName ) );
end
end


