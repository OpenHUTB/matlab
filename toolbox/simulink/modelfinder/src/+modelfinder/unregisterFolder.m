function unregisterFolder( pathToFolder, options )





























R36
pathToFolder{ mustBeA( pathToFolder, 'string' ), mustBeFolder }
options.verbose{ mustBeMember( options.verbose, { 'on', 'off' } ) } = 'off'
end 


for path = pathToFolder
modelfinder.internal.dataStore.unregisterFolder( path );
modelfinder.internal.dataStore.sync( 'path', path, 'verbose', options.verbose );
end 

end 

% Decoded using De-pcode utility v1.2 from file /tmp/tmpXNBLNF.p.
% Please follow local copyright laws when handling this file.

