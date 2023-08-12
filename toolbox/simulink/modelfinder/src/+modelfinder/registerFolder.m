function registerFolder( pathToFolder, options )





























R36
pathToFolder{ mustBeA( pathToFolder, 'string' ), mustBeFolder }
options.verbose{ mustBeMember( options.verbose, { 'on', 'off' } ) } = 'off'
end 


for path = pathToFolder
modelfinder.internal.dataStore.registerFolder( path, "verbose", options.verbose );
modelfinder.internal.dataStore.sync( 'path', path, 'verbose', options.verbose );
end 

end 

% Decoded using De-pcode utility v1.2 from file /tmp/tmpr8HNZP.p.
% Please follow local copyright laws when handling this file.

