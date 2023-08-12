function writeTlcAssignUserStructToSLStruct( h, fid, infoStruct, fcnInfo )%#ok<INUSL>





if fcnInfo.LhsArgs.NumArgs == 1
thisArg = fcnInfo.LhsArgs.Arg( 1 );
thisDataType = infoStruct.DataTypes.DataType( thisArg.DataTypeId );
if ( thisDataType.IsBus == 1 || thisDataType.IsStruct == 1 ) && strcmp( thisArg.Type, 'Output' )
fprintf( fid, '      /*\n' );
fprintf( fid, '       * Assign the Legacy Structure __%sBUS to the Simulink Structure %s\n',  ...
thisArg.Identifier, thisArg.Identifier );
fprintf( fid, '       */\n' );
fprintf( fid, '      %%assign dTypeId = LibBlockOutputSignalDataTypeId(%d)\n', thisArg.DataId - 1 );

thisData = legacycode.util.lct_pGetDataFromArg( infoStruct, thisArg );
if ( thisDataType.IsBus == 1 ) && ( thisData.Width == 1 ) && ( thisData.IsComplex == 0 )

fprintf( fid, '      %%<SLibAssignUserStructToSLStruct(dTypeId, "(char *)%s", "(*(%s *)__%sBUS)", 0)>\n',  ...
thisArg.Identifier, thisDataType.DTName, thisArg.Identifier );
else 

fprintf( fid, '      %%assign width = LibBlockOutputSignalWidth(%d)\n', thisArg.DataId - 1 );
fprintf( fid, '      %%assign optStar = ISEQUAL(width,1) ? "*" : ""\n' );
fprintf( fid, '      %%assign isCmplx = LibBlockOutputSignalIsComplex(%d)\n', thisArg.DataId - 1 );
fprintf( fid, '      %%<SLibAssignUserStructToSLStructND(dTypeId, width, "(char *)%s", "(%%<optStar>(%s *)__%sBUS)", Matrix(1,1) [0], 0, isCmplx)>\n',  ...
thisArg.Identifier, thisDataType.DTName, thisArg.Identifier );
end 

fprintf( fid, '\n' );
end 
end 

for ii = 1:fcnInfo.RhsArgs.NumArgs
thisArg = fcnInfo.RhsArgs.Arg( ii );
thisDataType = infoStruct.DataTypes.DataType( thisArg.DataTypeId );
if ( thisDataType.IsBus == 1 || thisDataType.IsStruct == 1 ) && strcmp( thisArg.Type, 'Output' )
fprintf( fid, '      /*\n' );
fprintf( fid, '       * Assign the Legacy Structure __%sBUS to the Simulink Structure %s\n',  ...
thisArg.Identifier, thisArg.Identifier );
fprintf( fid, '       */\n' );
fprintf( fid, '      %%assign dTypeId = LibBlockOutputSignalDataTypeId(%d)\n', thisArg.DataId - 1 );

thisData = legacycode.util.lct_pGetDataFromArg( infoStruct, thisArg );
if ( thisDataType.IsBus == 1 ) && ( thisData.Width == 1 ) && ( thisData.IsComplex == 0 )

fprintf( fid, '      %%<SLibAssignUserStructToSLStruct(dTypeId, "(char *)%s", "(*(%s *)__%sBUS)", 0)>\n',  ...
thisArg.Identifier, thisDataType.DTName, thisArg.Identifier );
else 

fprintf( fid, '      %%assign width = LibBlockOutputSignalWidth(%d)\n', thisArg.DataId - 1 );
fprintf( fid, '      %%assign optStar = ISEQUAL(width,1) ? "*" : ""\n' );
fprintf( fid, '      %%assign isCmplx = LibBlockOutputSignalIsComplex(%d)\n', thisArg.DataId - 1 );
fprintf( fid, '      %%<SLibAssignUserStructToSLStructND(dTypeId, width, "(char *)%s", "(%%<optStar>(%s *)__%sBUS)", Matrix(1,1) [0], 0, isCmplx)>\n',  ...
thisArg.Identifier, thisDataType.DTName, thisArg.Identifier );
end 

fprintf( fid, '\n' );
end 
end 

for ii = 1:fcnInfo.RhsArgs.NumArgs
thisArg = fcnInfo.RhsArgs.Arg( ii );
thisDataType = infoStruct.DataTypes.DataType( thisArg.DataTypeId );
if ( thisDataType.IsBus == 1 || thisDataType.IsStruct == 1 ) && strcmp( thisArg.Type, 'DWork' )
fprintf( fid, '      /*\n' );
fprintf( fid, '       * Assign the Legacy Structure __%sBUS to the Simulink Structure %s\n',  ...
thisArg.Identifier, thisArg.Identifier );
fprintf( fid, '       */\n' );
fprintf( fid, '      %%assign dTypeId = LibBlockDWorkDataTypeId(work%d)\n', thisArg.DataId );

thisData = legacycode.util.lct_pGetDataFromArg( infoStruct, thisArg );
if ( thisDataType.IsBus == 1 ) && ( thisData.Width == 1 ) && ( thisData.IsComplex == 0 )

fprintf( fid, '      %%<SLibAssignUserStructToSLStruct(dTypeId, "(char *)%s", "(*(%s *)__%sBUS)", 0)>\n',  ...
thisArg.Identifier, thisDataType.DTName, thisArg.Identifier );
else 

fprintf( fid, '      %%assign width = LibBlockDWorkWidth(work%d)\n', thisArg.DataId );
fprintf( fid, '      %%assign optStar = ISEQUAL(width,1) ? "*" : ""\n' );
fprintf( fid, '      %%assign isCmplx = LibBlockDWorkIsComplex(%d)\n', thisArg.DataId );
fprintf( fid, '      %%<SLibAssignUserStructToSLStructND(dTypeId, width, "(char *)%s", "(%%<optStar>(%s *)__%sBUS)", Matrix(1,1) [0], 0, isCmplx)>\n',  ...
thisArg.Identifier, thisDataType.DTName, thisArg.Identifier );
end 

fprintf( fid, '\n' );
end 
end 

% Decoded using De-pcode utility v1.2 from file /tmp/tmpfMlOzE.p.
% Please follow local copyright laws when handling this file.

