function businfoStruct = sfbWriteBusInfo( iP, oP, paramsList, fidExtern, busHeaderFile, busHeader, Sfunname, model )






















businfoStruct = [  ];




[ businfoStruct, num_buses_Inp ] = addDatatypes( businfoStruct, iP, oP, model );

fid_busHeader = fopen( busHeaderFile, 'w' );

if ( busHeader )
genBusHeader( fid_busHeader, businfoStruct, Sfunname, 1 );
fprintf( fidExtern, '%s\n', [ 'Gen_HeaderFile', '=', num2str( 1 ) ] );
else 
genBusHeader( fid_busHeader, businfoStruct, Sfunname, 0 );
fprintf( fidExtern, '%s\n', [ 'Gen_HeaderFile', '=', num2str( 0 ) ] );
end 

complex_param_flag = 0;
for i = 1:length( paramsList.Complexity )
if ( strcmp( paramsList.Complexity{ i }, 'COMPLEX_YES' ) )
complex_param_flag = 1;
end 
end 

if ~isempty( businfoStruct )
businfoStruct( end  ).complex_param_flag = complex_param_flag;
end 

fclose( fid_busHeader );
end 

function [ businfoStruct, num_buses_Inp ] = addDatatypes( businfoStruct, iP, oP, model )













builtinMap = containers.Map(  );




busVisitedMap = containers.Map(  );


idx = 0;


for i = 1:length( iP.Name )
[ builtinMap, busVisitedMap, businfoStruct, idx ] = addDatatype( businfoStruct, iP.Bus{ i }, iP.Busname{ i }, i, 1, model, builtinMap, busVisitedMap, idx );
end 

num_buses_Inp = length( businfoStruct );


for i = 1:length( oP.Name )
[ builtinMap, busVisitedMap, businfoStruct, idx ] = addDatatype( businfoStruct, oP.Bus{ i }, oP.Busname{ i }, i, 0, model, builtinMap, busVisitedMap, idx );
end 

if ~isempty( businfoStruct )
businfoStruct( end  ).numOffsets = idx + 1;
businfoStruct( end  ).builtinMap = builtinMap;
businfoStruct( end  ).busVisitedMap = busVisitedMap;
businfoStruct( end  ).model = getfullname( model );
end 

end 

function [ builtinMap, busVisitedMap, businfoStruct, idx ] = addDatatype( businfoStruct, isBus, busname, port_number, iflag, model, builtinMap, busVisitedMap, idx )

bus_structure = [  ];
if ~strcmp( isBus, 'on' )
return 
else 

[ builtinMap, busVisitedMap, bus_structure, idx ] = addRecurseDatatypeForNestedArrayOfBusesDriver( busname, bus_structure, builtinMap, busVisitedMap, idx, model );

len = length( businfoStruct );
businfoStruct( len + 1 ).bus_structure = bus_structure;
businfoStruct( len + 1 ).port_number = port_number - 1;
businfoStruct( len + 1 ).isinput_port = iflag;
end 
end 



function [ builtinMap, busVisitedMap, bus_structure, idx ] = addRecurseDatatypeForNestedArrayOfBusesDriver( busname, bus_structure, builtinMap, busVisitedMap, idx, model )

DataTypeNames = sfbGetBuiltinDataTypeNames(  );

buspath_latest = {  };%#ok<NASGU>



if ~existsInGlobalScope( model, busname )
return 
end 

[ builtinMap, busVisitedMap, bus_structure, idx ] = recurseBus( busname, builtinMap, busVisitedMap, idx,  ...
DataTypeNames, bus_structure, model );


end 

function [ builtinMap, busVisitedMap, bus_structure, idx ] = recurseBus( busName, builtinMap, busVisitedMap, idx,  ...
DataTypeNames, bus_structure, model )

if existsInGlobalScope( model, busName )
slObj = evalinGlobalScope( model, busName );
else 
return 
end 
index = length( bus_structure ) + 1;
subindex = 1;
bus_structure( index ).Name = busName;
bus_structure( index ).buselements = 0;
bus_structure( index ).buselementnames = {  };
bus_structure( index ).buselementsindex = [  ];
bus_structure( index ).cBusIdx = [  ];
bus_structure( index ).buselementsdimensions = {  };
bus_structure( index ).isNestedBusArray = false;

bus_structure( index ).builtinelementsindex = [  ];
bus_structure( index ).builtinelementsdimensions = {  };
bus_structure( index ).cBuiltinIdx = [  ];

bus_structure( index ).isFpt = {  };
bus_structure( index ).buselementsdatatype = {  };
bus_structure( index ).builtinelementsdatatype = {  };
bus_structure( index ).builtinelements = {  };
bus_structure( index ).Headerfile = {  };

if isa( slObj, 'Simulink.Bus' )
if ~isempty( strtrim( slObj.HeaderFile ) )
bus_structure( index ).Headerfile = slObj.HeaderFile;
end 

for i = 1:length( slObj.Elements )
if strcmp( slObj.Elements( i ).DimensionsMode, 'Variable' )
DAStudio.error( 'Simulink:SFunctionBuilder:ErrorVarDims', slObj.Elements( i ).Name, busName );
end 
if ~( ismember( slObj.Elements( i ).DataType, DataTypeNames ) || findFixdt( slObj.Elements( i ).DataType ) )

busDTStr = 'Bus:';
slObj.Elements( i ).DataType = strrep( slObj.Elements( i ).DataType, ' ', '' );
indicesBus = findstr( slObj.Elements( i ).DataType, busDTStr );
if ( ~isempty( indicesBus ) && indicesBus( 1 ) == 1 )
slObj.Elements( i ).DataType = strtrim( strrep( slObj.Elements( i ).DataType, 'Bus:', '' ) );
end 

EnumDTStr = 'Enum:';
indices = findstr( slObj.Elements( i ).DataType, EnumDTStr );
if ~( ( ~isempty( indices ) ) && ( indices( 1 ) == 1 ) )

bus_structure( index ).buselementnames = [ bus_structure( index ).buselementnames, slObj.Elements( i ).Name ];
bus_structure( index ).buselements = bus_structure( index ).buselements + 1;
bus_structure( index ).buselementsindex = [ bus_structure( index ).buselementsindex, i ];
bus_structure( index ).cBusIdx = [ bus_structure( index ).cBusIdx, idx ];
idx = idx + 1;
bus_structure( index ).buselementsdatatype = [ bus_structure( index ).buselementsdatatype, slObj.Elements( i ).DataType ];
bus_structure( index ).buselementsdimensions = [ bus_structure( index ).buselementsdimensions, prod( slObj.Elements( i ).Dimensions ) ];
if prod( slObj.Elements( i ).Dimensions ) > 1
bus_structure( index ).isNestedBusArray = true;
end 
[ builtinMap, busVisitedMap, bus_structure, idx ] = recurseBus( slObj.Elements( i ).DataType, builtinMap, busVisitedMap, idx,  ...
DataTypeNames, bus_structure, model );
else 

enumDataTypeName = slObj.Elements( i ).DataType( length( EnumDTStr ) + 1:end  );
bus_structure( index ).isFpt{ subindex } = false;
bus_structure( index ).cBuiltinIdx = [ bus_structure( index ).cBuiltinIdx, idx ];
idx = idx + 1;
bus_structure( index ).builtinelementsdatatype{ subindex } = enumDataTypeName;
bus_structure( index ).builtinelements{ subindex } = { slObj.Elements( i ).Name };
bus_structure( index ).builtinelementsdimensions{ subindex } = prod( slObj.Elements( i ).Dimensions );
bus_structure( index ).builtinelementscomplexity{ subindex } = 'real';

bus_structure( index ).builtinelementsindex = [ bus_structure( index ).builtinelementsindex, i ];
subindex = subindex + 1;
end 
else 

if ~builtinMap.isKey( slObj.Elements( i ).DataType )

datatype_Str = slObj.Elements( i ).DataType;
if ismember( datatype_Str, DataTypeNames )
switch datatype_Str
case 'double'
DT = 'real_T';
case 'single'
DT = 'real32_T';
otherwise 
DT = [ datatype_Str, '_T' ];
end 
builtinMap( datatype_Str ) = sprintf( [ 'sizeof(%s)' ], DT );
else 
builtinMap( datatype_Str ) = sprintf( [ 'dtaGetDataTypeSize(dta, bpath, ssGetDataTypeId(S, "%s"));' ], datatype_Str );
end 
end 

InDataType = slObj.Elements( i ).DataType;
bus_structure( index ).isFpt{ subindex } = false;
if findFixdt( InDataType )

argCell = regexp( InDataType( length( 'fixdt' ) + 2:end  - 1 ), ',', 'split' );
InIsComplex = strcmp( slObj.Elements( i ).Complexity, 'complex' );
InIsSigned = strcmp( argCell{ 1 }, '1' );
InWordLength = str2double( argCell{ 2 } );
keywordT = cell( 1, 1 );

if ( InWordLength > 64 )
DAStudio.error( 'Simulink:SFunctionBuilder:ErrorMultiWord', slObj.Elements( i ).Name, busName );
end 
keywordT( InWordLength <= 64 ) = { 'int64_T' };
keywordT( InWordLength <= 32 ) = { 'int32_T' };
keywordT( InWordLength <= 16 ) = { 'int16_T' };
keywordT( InWordLength <= 8 ) = { 'int8_T' };
keywordT( ~InIsSigned ) = cellfun( @( x )[ 'u', x ], keywordT( ~InIsSigned ), 'UniformOutput', false );
keywordT( InIsComplex ) = cellfun( @( x )[ 'c', x ], keywordT( InIsComplex ), 'UniformOutput', false );
InDataType = keywordT{ 1 };
bus_structure( index ).isFpt{ subindex } = true;
end 

bus_structure( index ).builtinelementsdimensions{ subindex } = prod( slObj.Elements( i ).Dimensions );
bus_structure( index ).builtinelementscomplexity{ subindex } = slObj.Elements( i ).Complexity;
bus_structure( index ).builtinelementsdatatype{ subindex } = [ InDataType ];
bus_structure( index ).builtinelementsdimensions{ subindex } = prod( slObj.Elements( i ).Dimensions );
bus_structure( index ).builtinelements{ subindex } = { slObj.Elements( i ).Name };
bus_structure( index ).builtinelementsindex = [ bus_structure( index ).builtinelementsindex, i ];
bus_structure( index ).cBuiltinIdx = [ bus_structure( index ).cBuiltinIdx, idx ];
idx = idx + 1;
subindex = subindex + 1;
end 
end 

if ~busVisitedMap.isKey( busName )
tempStruct = struct;
tempStruct.builtinInBusIdx = bus_structure( index ).builtinelementsindex;
tempStruct.builtinCIdx = bus_structure( index ).cBuiltinIdx;
tempStruct.builtinDType = bus_structure( index ).builtinelementsdatatype;
tempStruct.builtinNumElems = bus_structure( index ).builtinelementsdimensions;
tempStruct.busInBusIdx = bus_structure( index ).buselementsindex;
tempStruct.busCIdx = bus_structure( index ).cBusIdx;
tempStruct.busDType = bus_structure( index ).buselementsdatatype;
tempStruct.busNumElems = bus_structure( index ).buselementsdimensions;
tempStruct.isFpt = bus_structure( index ).isFpt;
tempStruct.isNestedBusArray = bus_structure( index ).isNestedBusArray;
busVisitedMap( busName ) = tempStruct;
end 


end 


end 

function res = findFixdt( dtype )

isBus = false;
isEnum = false;

busDTStr = 'Bus:';
dtype = strrep( dtype, ' ', '' );
indicesBus = findstr( dtype, busDTStr );
if ( ~isempty( indicesBus ) && indicesBus( 1 ) == 1 )
isBus = true;
end 

EnumDTStr = 'Enum:';
indices = findstr( dtype, EnumDTStr );
if ( ~isempty( indices ) ) && ( indices( 1 ) == 1 )
isEnum = true;
end 

res = false;
if ~isEnum && ~isBus
idx = findstr( dtype, 'fixdt' );

if ~isempty( idx )
res = true;
end 
else 
res = false;
end 

end 


function genBusHeader( fid_busHeader, businfoStruct, Sfunname, flag )








if ( flag )
genNewBusHeader( fid_busHeader, businfoStruct, Sfunname );
else 
genListOfHeaders( fid_busHeader, businfoStruct );
end 

end 


function genListOfHeaders( fid_busHeader, businfoStruct )
list_headers = {  };
for i = 1:length( businfoStruct )
for j = 1:length( businfoStruct( i ).bus_structure )
list_headers = [ list_headers, businfoStruct( i ).bus_structure( j ).Headerfile ];%#ok<AGROW>
end 
end 
list_headers = unique( list_headers );
for i = 1:length( list_headers )
fprintf( fid_busHeader, [ '#include "', list_headers{ i }, '"\n' ] );
end 
end 

function genNewBusHeader( fid_busHeader, businfoStruct, Sfunname )
fprintf( fid_busHeader, '\n\nSETUP_BUSHEADER=/* Generated by S-function Builder */\n' );
fprintf( fid_busHeader, [ 'SETUP_BUSHEADER=#ifndef _', upper( Sfunname ), '_BUS_H_\n' ] );
fprintf( fid_busHeader, [ 'SETUP_BUSHEADER=#define _', upper( Sfunname ), '_BUS_H_\n' ] );
fprintf( fid_busHeader, 'SETUP_BUSHEADER=/* Read only - STARTS */\n' );

fprintf( fid_busHeader, 'SETUP_BUSHEADER=#ifdef MATLAB_MEX_FILE\n' );
fprintf( fid_busHeader, 'SETUP_BUSHEADER=#include "tmwtypes.h"\n' );
fprintf( fid_busHeader, 'SETUP_BUSHEADER=#else\n' );
fprintf( fid_busHeader, 'SETUP_BUSHEADER=#include "rtwtypes.h"\n' );
fprintf( fid_busHeader, 'SETUP_BUSHEADER=#endif\n\n' );

busnames_defined = {  };
buses_to_define = {  };
list_of_headers = {  };




for i = 1:length( businfoStruct )
for j = length( businfoStruct( i ).bus_structure ): - 1:1
typedef_str = [ '\n#ifndef DEFINED_TYPEDEF_FOR_', businfoStruct( i ).bus_structure( j ).Name,  ...
'_\n#define DEFINED_TYPEDEF_FOR_', businfoStruct( i ).bus_structure( j ).Name, '_ \ntypedef struct {\n' ];
if ( isempty( businfoStruct( i ).bus_structure( j ).Headerfile ) )
struct_str = businfoStruct( i ).bus_structure( j ).Name;
str_found = findStruct_Str( struct_str, busnames_defined );
busnames_defined = [ busnames_defined, struct_str ];%#ok<AGROW>
if ( ~str_found )
fprintf( fid_busHeader, typedef_str );
busElemLength = 0;
builtinElemLength = 0;
for elemLength = 1:businfoStruct( i ).bus_structure( j ).buselements + length( businfoStruct( i ).bus_structure( j ).builtinelements )











isBusElementIndex = false;
for kk = 1:length( businfoStruct( i ).bus_structure( j ).buselementsindex )
if ( businfoStruct( i ).bus_structure( j ).buselementsindex( kk ) == elemLength )%#ok<ST2NM>
isBusElementIndex = true;
break ;
end 
end 
if isBusElementIndex
busElemLength = busElemLength + 1;
fprintf( fid_busHeader, '  ' );
fprintf( fid_busHeader, businfoStruct( i ).bus_structure( j ).buselementsdatatype{ busElemLength } );
busElementDims = businfoStruct( i ).bus_structure( j ).buselementsdimensions{ busElemLength };
fprintf( fid_busHeader, ' ' );
fprintf( fid_busHeader, businfoStruct( i ).bus_structure( j ).buselementnames{ busElemLength } );
if busElementDims > 1
fprintf( fid_busHeader, '[' );
fprintf( fid_busHeader, string( busElementDims ) );
fprintf( fid_busHeader, ']' );
end 
fprintf( fid_busHeader, ';\n' );
buses_to_define = [ buses_to_define, businfoStruct( i ).bus_structure( j ).buselementsdatatype{ busElemLength } ];%#ok<AGROW>
else 
builtinElemLength = builtinElemLength + 1;
fprintf( fid_busHeader, '  ' );
write_Cdatatype( fid_busHeader, businfoStruct( i ).bus_structure( j ).builtinelementsdatatype{ builtinElemLength },  ...
businfoStruct( i ).bus_structure( j ).builtinelementscomplexity{ builtinElemLength },  ...
businfoStruct( i ).bus_structure( j ).isFpt{ builtinElemLength } );

fprintf( fid_busHeader, ' ' );
fprintf( fid_busHeader, businfoStruct( i ).bus_structure( j ).builtinelements{ builtinElemLength }{ 1 } );
dimension = 1;
for kk = 1:length( businfoStruct( i ).bus_structure( j ).builtinelementsdimensions{ builtinElemLength } )
dimension = dimension * businfoStruct( i ).bus_structure( j ).builtinelementsdimensions{ builtinElemLength }( kk );
end 
if dimension > 1
fprintf( fid_busHeader, [ '[', num2str( dimension ), ']' ] );
end 
fprintf( fid_busHeader, ';\n' );
end 
end 
fprintf( fid_busHeader, [ '} ', businfoStruct( i ).bus_structure( j ).Name, ';\n#endif\n\n' ] );
end 
else 
str_found = findStruct_Str( businfoStruct( i ).bus_structure( j ).Name, buses_to_define );
if ( ~str_found )
list_of_headers = [ list_of_headers, businfoStruct( i ).bus_structure( j ).Headerfile ];%#ok<AGROW>
end 
end 
end 
end 
fprintf( fid_busHeader, '/* Read only - ENDS */\n' );


list_of_headers = unique( list_of_headers );

for ii = 1:length( list_of_headers )
fprintf( fid_busHeader, [ '\nINCLUDE_FILES=#include "', list_of_headers{ ii }, '"' ] );
end 
end 


function write_Cdatatype( fid_busHeader, datatype_Str, complexityStr, isFpt )

DT = datatype_Str;
if ~isFpt
switch datatype_Str
case 'double'
DT = 'real_T';
case 'single'
DT = 'real32_T';
otherwise 
DT = [ datatype_Str, '_T' ];
end 

if strcmpi( complexityStr, 'complex' )
DT = [ 'c', DT ];
end 

end 
fprintf( fid_busHeader, DT );
end 



function str_found = findStruct_Str( struct_str, busnames )
str_found = 0;
for i = 1:length( busnames )
if ( strcmp( busnames{ i }, struct_str ) )
str_found = 1;
break ;
end 
end 
end 





% Decoded using De-pcode utility v1.2 from file /tmp/tmpjAKPAE.p.
% Please follow local copyright laws when handling this file.

