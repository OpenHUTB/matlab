function status = unregisterAdapter( adapterClassName )



R36
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
% Decoded using De-pcode utility v1.2 from file /tmp/tmp7X2JnM.p.
% Please follow local copyright laws when handling this file.

