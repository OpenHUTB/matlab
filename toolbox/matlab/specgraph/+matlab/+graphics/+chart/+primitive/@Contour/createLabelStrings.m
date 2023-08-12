function strs = createLabelStrings( hObj, levels, format )




R36
hObj( 1, 1 )matlab.graphics.chart.primitive.Contour
levels( 1, : )
format = hObj.LabelFormat
end 



labelCache = hObj.LabelCache;
if isfield( labelCache, 'Levels' ) && isequal( labelCache.Levels, levels ) &&  ...
isfield( labelCache, 'Format' ) && isequal( labelCache.Format, format ) &&  ...
isfield( labelCache, 'Labels' )
strs = labelCache.Labels;
return 
end 

invalidLabelFormatMessage = getString( message( 'MATLAB:contour:InvalidLabelFormat' ) );
if isa( format, 'function_handle' )

try 
out = format( levels );
catch caughtError
err = MException( message( 'MATLAB:contour:LabelFormatFunctionError',  ...
func2str( format ), invalidLabelFormatMessage ) );
throwAsCaller( err.addCause( caughtError ) );
end 


try 
strs = string( out );
catch caughtError
err = MException( message( 'MATLAB:contour:LabelFormatFunctionInvalidOutput',  ...
func2str( format ), invalidLabelFormatMessage ) );
throwAsCaller( err.addCause( caughtError ) );
end 


if numel( strs ) ~= numel( levels )
err = MException( message( 'MATLAB:contour:LabelFormatFunctionInvalidOutput',  ...
func2str( format ), invalidLabelFormatMessage ) );
throwAsCaller( err );
end 
elseif ischar( format ) || isStringScalar( format )

try 
out = compose( format, levels );
catch caughtError
err = MException( message( 'MATLAB:contour:LabelFormatStringError',  ...
format, invalidLabelFormatMessage ) );
throwAsCaller( err.addCause( caughtError ) );
end 



try 
strs = string( out );
assert( numel( strs ) == numel( levels ) )
catch 
err = MException( message( 'MATLAB:contour:LabelFormatStringInvalidOutput',  ...
format, invalidLabelFormatMessage ) );
throwAsCaller( err );
end 
else 
throwAsCaller( MException( message( 'MATLAB:contour:InvalidLabelFormat' ) ) );
end 


hObj.LabelCache = struct( 'Levels', levels, 'Format', format, 'Labels', strs );

end 



% Decoded using De-pcode utility v1.2 from file /tmp/tmpfUD3db.p.
% Please follow local copyright laws when handling this file.

