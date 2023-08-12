function rst = isUsingAnyDataDictionary( model )













assert( ischar( model ) );
load_system( model );

mdlDD = get_param( model, 'DataDictionary' );
if ~isempty( mdlDD )
rst = true;
return ;
end 

bdObj = get_param( model, 'slobject' );
broker = bdObj.getBroker;
srcs = broker.getExternalReferenceURLs( '#BROKEREDSLDD' );
if ~isempty( srcs )
rst = true;
return ;
end 
rst = false;
end 

% Decoded using De-pcode utility v1.2 from file /tmp/tmp4NZ3Il.p.
% Please follow local copyright laws when handling this file.

