function app = compare( first, second, options )




R36
first( 1, 1 )comparisons.internal.FileSource
second( 1, 1 )comparisons.internal.FileSource
options( 1, 1 ){ mustBeTwoWayOptions } = comparisons.internal.makeTwoWayOptions(  )
end 


fileOrFolderMustExist( first );
fileOrFolderMustExist( second );

args = { first, second, options };
try 
app = comparisons.internal.dispatchToProvider( "DiffGUIProviders", args );
catch ex
throwAsCaller( ex );
end 

handled = ~isempty( app );
if handled
return ;
end 

if comparisons.internal.isMOTW(  )
error( message( 'comparisons:mldesktop:MOTWNotSupported' ) );
else 
error( message( 'comparisons:mldesktop:UnableToCompare',  ...
first.Path, second.Path ) );
end 
end 

function fileOrFolderMustExist( fileSource )
if ( ~isfile( fileSource.Path ) && ~isfolder( fileSource.Path ) )
msg = message( 'comparisons:mldesktop:FileNotFound', fileSource.Path );
error( msg );
end 
end 

function mustBeTwoWayOptions( arg )
mustBeA( arg, 'comparisons.internal.TwoWayOptions' );
end 

% Decoded using De-pcode utility v1.2 from file /tmp/tmpP3r2N1.p.
% Please follow local copyright laws when handling this file.

