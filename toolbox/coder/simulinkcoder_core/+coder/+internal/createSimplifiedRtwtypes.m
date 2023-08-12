function createSimplifiedRtwtypes( targetFolder, componentFolder, rtwtypesStyle )





R36
targetFolder
componentFolder
rtwtypesStyle = 'minimized'
end 


codeDescriptor = coder.internal.getCodeDescriptorInternal( componentFolder );
ci = codeDescriptor.getFullComponentInterface;
platformTypes = ci.PlatformDataTypes;

if isempty( platformTypes )





return 
end 





basicTypeHeaders = coder.internal.getHeadersForSymbols ...
( ci, { 'uint32_T', 'boolean_T', 'real_T' } );


rtwtypesFile = fullfile( targetFolder, 'rtwtypes.h' );
i_genSimplifiedRtwtypes( rtwtypesFile, ci, basicTypeHeaders, rtwtypesStyle )




function i_genSimplifiedRtwtypes( rtwtypesFile, ci, basicTypeHeaders,  ...
rtwtypesStyle )

cstdintIdx = strcmp( basicTypeHeaders, '<cstdint>' );

if any( cstdintIdx )



basicTypeHeaders = unique( [ basicTypeHeaders( ~cstdintIdx ) ...
, { '<stdint.h>', '<stdbool.h>' } ], 'stable' );


expr = '^std::';
else 

expr = '';
end 

compatibilityComment = [  ...
'/*', newline ...
, ' * File: rtwtypes.h', newline ...
, ' *', newline ...
, ' * This version of rtwtypes.h is generated for compatibility with custom', newline ...
, ' * source code or static source files that are located under matlabroot.', newline ...
, ' * Automatically generated code does not have to include this file.', newline ...
, ' */', newline ];

[ startIncludeGuard, endIncludeGuard ] = i_getIncludeGuards( 'RTWTYPES_H' );

f = fopen( rtwtypesFile, 'wt' );
fCloseFcn = onCleanup( @(  )fclose( f ) );

fprintf( f, '%s\n', compatibilityComment );

fprintf( f, '%s\n', startIncludeGuard );

if strcmp( rtwtypesStyle, 'full' )
basicTypeHeaders{ end  + 1 } = '<stddef.h>';
end 

for i = 1:length( basicTypeHeaders )
fprintf( f, '#include %s\n', basicTypeHeaders{ i } );
end 
fprintf( f, '\n' );

typeMapping = [ 
"int8_T", "int8"
"uint8_T", "uint8"
"int16_T", "int16"
"uint16_T", "uint16"
"int32_T", "int32"
"uint32_T", "uint32"
"int64_T", "int64"
"uint64_T", "uint64"
"boolean_T", "boolean"
"real_T", "double"
"real32_T", "single"
"time_T", "double"
 ];
n = length( typeMapping( :, 1 ) );
defs( 1:n ) = "";
for i = 1:n
classicName = typeMapping( i, 1 );
mappedType = ci.getPlatformDataTypeByName( typeMapping( i, 2 ) );
if ~isempty( mappedType )
mappedName = regexprep( mappedType.Symbol, expr, '', 'once' );
defs( i ) = "typedef" + " " + mappedName + " " + classicName + ";";
end 
end 
defs = defs( defs ~= "" );

defs = [ defs ...
, "typedef unsigned int uint_T;" ...
, "typedef int int_T;" ...
, "typedef char char_T;" ];

defs = join( defs, newline );

fprintf( f, '%s\n\n', defs );


if strcmp( rtwtypesStyle, 'full' )




mwSizesDefs = [ 
"/* mxArray size and index values */"
"#ifdef MX_COMPAT_32"
"typedef int mwSize;"
"typedef int mwIndex;"
"typedef int mwSignedIndex;"
"#else"
"typedef size_t mwSize;"
"typedef size_t mwIndex;"
"typedef ptrdiff_t mwSignedIndex;"
"#endif" ];
mwSizesDefs = join( mwSizesDefs, newline );
fprintf( f, '%s\n\n', mwSizesDefs );
end 


fprintf( f, '%s', endIncludeGuard );

delete( fCloseFcn );




function [ startIncludeGuard, endIncludeGuard ] = i_getIncludeGuards( guardName )
startIncludeGuard = [ '#ifndef ', guardName, newline, '#define ', guardName, newline ];
endIncludeGuard = [ '#endif /* ', guardName, ' */', newline ];

% Decoded using De-pcode utility v1.2 from file /tmp/tmpiJU9HN.p.
% Please follow local copyright laws when handling this file.

