function app = merge( theirs, base, mine, options )




R36
theirs( 1, 1 )comparisons.internal.FileSource
base( 1, 1 )comparisons.internal.FileSource
mine( 1, 1 )comparisons.internal.FileSource
options( 1, 1 ){ mustBeThreeWayOptions } = comparisons.internal.makeThreeWayOptions(  )
end 


fileOrFolderMustExist( theirs )
fileOrFolderMustExist( base )
fileOrFolderMustExist( mine )

try 
app = handleThreeWay( theirs, base, mine, options );
if isempty( app )
app = handleTwoWay( theirs, mine, options );
end 
catch ex
throwAsCaller( ex );
end 
end 

function app = handleThreeWay( theirs, base, mine, options )
args = { theirs, base, mine, options };
app = comparisons.internal.dispatchToProvider( "Merge3GUIProviders", args );
end 

function app = handleTwoWay( theirs, mine, options )
options = convertToTwoWayOptions( options );
app = comparisons.internal.gui.compare( theirs, mine, options );
end 

function twoWayOpts = convertToTwoWayOptions( threeWayOpts )
twoWayOpts = comparisons.internal.TwoWayOptions( threeWayOpts );
twoWayOpts.EnableSwapSides = false;
end 

function fileOrFolderMustExist( fileSource )
if ( ~isfile( fileSource.Path ) && ~isfolder( fileSource.Path ) )
msg = message( 'comparisons:mldesktop:FileNotFound', fileSource.Path );
error( msg );
end 
end 

function mustBeThreeWayOptions( arg )
mustBeA( arg, 'comparisons.internal.ThreeWayOptions' );
end 

% Decoded using De-pcode utility v1.2 from file /tmp/tmpuxw2VK.p.
% Please follow local copyright laws when handling this file.

