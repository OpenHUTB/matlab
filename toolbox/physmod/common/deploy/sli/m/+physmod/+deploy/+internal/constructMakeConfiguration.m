function makeCfg = constructMakeConfiguration( libraryIds, precompile, metadataDirectory )












































arguments
    libraryIds( :, 1 )string;
    precompile( 1, 1 )logical = physmod.deploy.internal.usePrecompiledLibraries;
    metadataDirectory( 1, 1 )string = physmod.deploy.internal.metadataDirectory;
end


metadata = physmod.deploy.internal.loadLibraryMetadata( libraryIds, metadataDirectory );


makeCfg.includePath = unique( { metadata.PathToHeaders } );
makeCfg.precompile = precompile;



noModules = arrayfun( @( x )isempty( x.Modules ), metadata );
libraryIds( noModules ) = [  ];
metadata( noModules ) = [  ];

makeCfg.sourcePath = unique( { metadata.PathToModules } );



makeCfg.library = struct(  ...
    Name = toCol( cellstr( libraryIds ) ),  ...
    Location = toCol( { metadata.PathToStaticLibraries } ),  ...
    Modules = toCol( { metadata.Modules } ) );

end

function out = toCol( in )

out = reshape( in, [  ], 1 );
end


