function status = registerAdapter( adapterClassName )

arguments
    adapterClassName( 1, 1 )string
end

try
    adapter = eval( adapterClassName );%#ok<NASGU> Check to see if it can be instantiated prior to continuing

    status = sl.data.adapter.AdapterManagerV2.registerMatlabAdapter( adapterClassName );
catch ex
    status = false;
    warning( ex.identifier, '%s', ex.message );
end
end
