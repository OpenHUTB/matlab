function status = unregisterAdapter( adapterClassName )

arguments
    adapterClassName( 1, 1 )string
end

classList = sl.data.adapter.AdapterManagerV2.getMCOSAdapterClasses;
if any( contains( classList, adapterClassName ) )
    try
        adapter = eval( adapterClassName );
        adapterDisplayName = adapter.getAdapterName(  );
        status = sl.data.adapter.AdapterManagerV2.unregisterAdapterByName( adapterDisplayName );
    catch ex
        status = false;
        warning( ex.identifier, '%s', ex.message );
    end
else
    status = false;
    warning( 'sl_data_adapter:messages:UnregisterAdapterClassnameNotFound', DAStudio.message( 'sl_data_adapter:messages:UnregisterAdapterClassnameNotFound', adapterClassName ) );
end
end
