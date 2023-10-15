function unregisterFolder( pathToFolder, options )

arguments
    pathToFolder{ mustBeA( pathToFolder, 'string' ), mustBeFolder }
    options.verbose{ mustBeMember( options.verbose, { 'on', 'off' } ) } = 'off'
end


for path = pathToFolder
    modelfinder.internal.dataStore.unregisterFolder( path );
    modelfinder.internal.dataStore.sync( 'path', path, 'verbose', options.verbose );
end

end
