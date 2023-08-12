function writeTlcTempVariableFor2DMatrix( ~, fid, infoStruct, fcnInfo, fromWrapper )





if nargin < 5
fromWrapper = false;
end 

for ii = 1:fcnInfo.RhsArgs.NumArgs
thisArg = fcnInfo.RhsArgs.Arg( ii );
if strcmp( thisArg.Type, 'SizeArg' )
continue 
end 

thisData = legacycode.util.lct_pGetDataFromArg( infoStruct, thisArg );
if thisData.CMatrix2D.DWorkId > 0 && ismember( thisArg.Type, { 'Input', 'Parameter', 'Output' } )
nWriteTempVariable( thisData, thisArg.DataId - 1, thisArg.Type );
end 
end 

if fcnInfo.LhsArgs.NumArgs == 1
thisArg = fcnInfo.LhsArgs.Arg( 1 );
thisData = legacycode.util.lct_pGetDataFromArg( infoStruct, thisArg );

if thisData.CMatrix2D.DWorkId > 0
nWriteTempVariable( thisData, thisArg.DataId, thisArg.Type );
end 
end 

function nWriteTempVariable( thisData, dataId, dataKind )

switch dataKind
case 'Input'
dworkAddrStr = sprintf( 'LibBlockDWorkAddr(u%dM2D, "", "", 0)', dataId + 1 );
dataAddrStr = sprintf( 'LibBlockInputSignalAddr(%d, "", "", 0)', dataId );
dtId = sprintf( 'LibBlockInputSignalDataTypeId(%d)', dataId );

case 'Parameter'
dworkAddrStr = sprintf( 'LibBlockDWorkAddr(p%dM2D, "", "", 0)', dataId + 1 );
dataAddrStr = sprintf( 'LibBlockParameterBaseAddr(p%d)', dataId + 1 );
dtId = sprintf( 'LibBlockParameterDataTypeId(%d)', dataId );

case 'Output'
dworkAddrStr = sprintf( 'LibBlockDWorkAddr(y%dM2D, "", "", 0)', dataId + 1 );
dataAddrStr = sprintf( 'LibBlockOutputSignalAddr(%d, "", "", 0)', dataId );
dtId = sprintf( 'LibBlockOutputSignalDataTypeId(%d)', dataId );

otherwise 

end 

dtName = sprintf( 'LibGetDataTypeNameFromId(%s)', dtId );



if ~fromWrapper
fprintf( fid, '     %%<%s>* __%sM2D = (%%<%s>*)%%<%s>;\n',  ...
dtName, thisData.Identifier, dtName, dworkAddrStr );
end 

thisDataType = infoStruct.DataTypes.DataType( thisData.DataTypeId );
isBus = ( thisDataType.IsBus == 1 || thisDataType.IsStruct == 1 );





if fromWrapper
if ~isBus
fprintf( fid, '     %%<%s>* __%sBUS = (%%<%s>*)%s;\n',  ...
dtName, thisData.Identifier, dtName, thisData.Identifier );
end 
else 
fprintf( fid, '     %%<%s>* __%sBUS = (%%<%s>*)%%<%s>;\n',  ...
dtName, thisData.Identifier, dtName, dataAddrStr );
end 
end 

end 


% Decoded using De-pcode utility v1.2 from file /tmp/tmpgftL0A.p.
% Please follow local copyright laws when handling this file.

