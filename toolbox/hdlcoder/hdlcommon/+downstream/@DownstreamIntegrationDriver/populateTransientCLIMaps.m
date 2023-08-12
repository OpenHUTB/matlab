function populateTransientCLIMaps( obj )




if isempty( obj.transientCLIMaps )
cli = hdlcoderprops.CLI;
transientCLIs = cli.getTransientPropNameList;
transientCLIDefaults = cell( size( transientCLIs ) );
for i = 1:length( transientCLIs )
transientCLIDefaults{ i } = cli.( transientCLIs{ i } );
end 
obj.transientCLIMaps = containers.Map( transientCLIs, transientCLIDefaults );
end 

end 
% Decoded using De-pcode utility v1.2 from file /tmp/tmppSXEdD.p.
% Please follow local copyright laws when handling this file.

