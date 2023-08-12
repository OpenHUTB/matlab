function out = visdiff( filename1, filename2, type )



















R36
filename1
filename2
type( 1, 1 )string = ""
end 

import comparisons.internal.dispatcherutil.parse
import comparisons.internal.fileutil.resolvePath

narginchk( 2, 3 );

parse( 'visdiff', filename1, filename2 );

filePath1 = resolvePath( filename1 );
filePath2 = resolvePath( filename2 );

if nargout == 0
handled = false;
try 
handled = dispatchNoJavaVisdiffGUI( filePath1, filePath2, type );
catch ex
ex.throwAsCaller(  );
end 
if ~handled
if type ~= ""
error( message( 'comparisons:mldesktop:UnknownComparisonType', type ) );
else 
error( message( 'comparisons:mldesktop:UnableToCompare', filename1, filename2 ) );
end 
end 
elseif nargout == 1
out = '';
try 
out = dispatchNoJavaVisdiffNoGUI( filePath1, filePath2, type );
catch ex
ex.throwAsCaller(  );
end 
if isempty( out )
if type ~= ""
error( message( 'comparisons:mldesktop:UnknownComparisonTypeForNoDisplay', type ) );
else 
error( message( 'comparisons:mldesktop:CannotCompareWithoutDisplay', filePath1, filePath2 ) );
end 
end 
end 
end 

function handled = dispatchNoJavaVisdiffGUI( filePath1, filePath2, comparisonType )
args = createDispatcherArguments( filePath1, filePath2, comparisonType );
app = comparisons.internal.dispatchToProvider( "DiffGUIProviders", args );
handled = ~isempty( app );
if handled
comparisons.internal.appstore.register( app );
end 
end 

function out = dispatchNoJavaVisdiffNoGUI( filePath1, filePath2, comparisonType )
args = createDispatcherArguments( filePath1, filePath2, comparisonType );
out = comparisons.internal.dispatchToNoGUIProvider( "DiffNoGUIProviders", args );
end 

function args = createDispatcherArguments( filePath1, filePath2, comparisonType )
fileSource1 = comparisons.internal.makeFileSource( filePath1 );
fileSource2 = comparisons.internal.makeFileSource( filePath2 );
options = comparisons.internal.makeTwoWayOptions( type = comparisonType );

args = { fileSource1, fileSource2, options };
end 

% Decoded using De-pcode utility v1.2 from file /tmp/tmpj7nzuO.p.
% Please follow local copyright laws when handling this file.

