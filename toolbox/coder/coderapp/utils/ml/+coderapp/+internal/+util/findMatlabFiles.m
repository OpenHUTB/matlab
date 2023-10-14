function results = findMatlabFiles( folders )

arguments
    folders string = getUserFolders(  )
end


totalFolders = numel( folders );
files = cell( 1, totalFolders );
for i = 1:totalFolders
    files{ i } = listMatlabFiles( folders( i ) );
end

keepGoing = true( 1, totalFolders );
depth = 1;



while any( keepGoing )
    pkgPat = repmat( '+*/', 1, depth );
    for i = find( keepGoing )
        keepGoing( i ) = ~isempty( listFiles( folders( i ), pkgPat ) );
        if keepGoing( i )


            files{ i } = [ files{ i }, listMatlabFiles( fullfile( folders( i ), pkgPat ) ) ];
        end
    end
    depth = depth + 1;
end


files = [ files{ : } ]';
symbols = cell( size( files ) );
for i = 1:numel( files )
    symbols{ i } = coderapp.internal.util.getQualifiedFileName( files{ i } );
end


results = struct( 'file', files, 'symbol', symbols );
isInvalid = cellfun( 'isempty', regexp( symbols,  ...
    '^([A-Za-z][_A-Za-z0-9]*)(\.[A-Za-z][_A-Za-z0-9]*)*$', 'once' ) );
results( isInvalid ) = [  ];
end


function folders = getUserFolders(  )

folders = strsplit( path(  ), pathsep(  ) );

currentFolder = pwd;
if ~ismember( currentFolder, folders )
    folders{ end  + 1 } = currentFolder;
end

folders( startsWith( folders, matlabroot(  ) ) ) = [  ];

end


function files = listMatlabFiles( root )
arguments
    root( 1, 1 )string
end
files = [ listFiles( root, '*.m' ), listFiles( root, '*.mlx' ) ];
end


function files = listFiles( root, pat )
arguments
    root( 1, 1 )string
    pat( 1, 1 )string
end

files = dir( root + filesep + pat );
files = fullfile( { files.folder }, { files.name } );
end


