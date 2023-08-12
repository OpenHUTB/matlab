function libDD = getAllDictionariesOfLibrary( model )













if isempty( model )
libDD = {  };
return 
end 

bdObj = get_param( model, 'slobject' );

broker = bdObj.getBroker;


if bdIsLibrary( model )
srcs = broker.lookUpDictionariesForLibrary( bdObj.FileName, true );
else 
srcs = broker.getExternalReferenceURLs( '#BROKEREDSLDD' );
end 

libDD = cellfun( @( x )slid.broker.Resource.getFileNameWithExtension( x ), srcs,  ...
'UniformOutput', false );

end 



% Decoded using De-pcode utility v1.2 from file /tmp/tmpVG4OLp.p.
% Please follow local copyright laws when handling this file.

