function writeTlcAssignSLStructToUserStruct( h, fid, infoStruct, fcnInfo )%#ok<INUSL>





for ii = 1:fcnInfo.RhsArgs.NumArgs
thisArg = fcnInfo.RhsArgs.Arg( ii );
thisDataType = infoStruct.DataTypes.DataType( thisArg.DataTypeId );
if ( thisDataType.IsBus == 1 || thisDataType.IsStruct == 1 ) && strcmp( thisArg.Type, 'Input' )
fprintf( fid, '      /*\n' );
fprintf( fid, '       * Assign the Simulink Structure %s to Legacy Structure __%sBUS\n',  ...
thisArg.Identifier, thisArg.Identifier );
fprintf( fid, '       */\n' );
fprintf( fid, '      %%assign dTypeId = LibBlockInputSignalDataTypeId(%d)\n', thisArg.DataId - 1 );

thisData = legacycode.util.lct_pGetDataFromArg( infoStruct, thisArg );
if ( thisDataType.IsBus == 1 ) && ( thisData.Width == 1 ) && ( thisData.IsComplex == 0 )

fprintf( fid, '      %%<SLibAssignSLStructToUserStruct(dTypeId, "(*(%s *)__%sBUS)", "(char *)%s", 0)>\n',  ...
thisDataType.DTName, thisArg.Identifier, thisArg.Identifier );
else 

fprintf( fid, '      %%assign width = LibBlockInputSignalWidth(%d)\n', thisArg.DataId - 1 );
fprintf( fid, '      %%assign optStar = ISEQUAL(width,1) ? "*" : ""\n' );
fprintf( fid, '      %%assign isCmplx = LibBlockInputSignalIsComplex(%d)\n', thisArg.DataId - 1 );
fprintf( fid, '      %%<SLibAssignSLStructToUserStructND(dTypeId, width, "(%%<optStar>(%s *)__%sBUS)", "(char *)%s", Matrix(1,1) [0], 0, isCmplx)>\n',  ...
thisDataType.DTName, thisArg.Identifier, thisArg.Identifier );
end 

fprintf( fid, '\n' );
end 
end 

for ii = 1:fcnInfo.RhsArgs.NumArgs
thisArg = fcnInfo.RhsArgs.Arg( ii );
thisDataType = infoStruct.DataTypes.DataType( thisArg.DataTypeId );
if ( thisDataType.IsBus == 1 || thisDataType.IsStruct == 1 ) && strcmp( thisArg.Type, 'DWork' )
fprintf( fid, '      /*\n' );
fprintf( fid, '       * Assign the Simulink Structure %s to Legacy Structure __%sBUS\n',  ...
thisArg.Identifier, thisArg.Identifier );
fprintf( fid, '       */\n' );
fprintf( fid, '      %%assign dTypeId = LibBlockDWorkDataTypeId(work%d)\n', thisArg.DataId );

thisData = legacycode.util.lct_pGetDataFromArg( infoStruct, thisArg );
if ( thisDataType.IsBus == 1 ) && ( thisData.Width == 1 ) && ( thisData.IsComplex == 0 )

fprintf( fid, '      %%<SLibAssignSLStructToUserStruct(dTypeId, "(*(%s *)__%sBUS)", "(char *)%s", 0)>\n',  ...
thisDataType.DTName, thisArg.Identifier, thisArg.Identifier );
else 

fprintf( fid, '      %%assign width = LibBlockDWorkWidth(work%d)\n', thisArg.DataId );
fprintf( fid, '      %%assign optStar = ISEQUAL(width,1) ? "*" : ""\n' );
fprintf( fid, '      %%assign isCmplx = LibBlockDWorkIsComplex(work%d)\n', thisArg.DataId );
fprintf( fid, '      %%<SLibAssignSLStructToUserStructND(dTypeId, width, "(%%<optStar>(%s *)__%sBUS)", "(char *)%s", Matrix(1,1) [0], 0, isCmplx)>\n',  ...
thisDataType.DTName, thisArg.Identifier, thisArg.Identifier );
end 

fprintf( fid, '\n' );
end 
end 

for ii = 1:fcnInfo.RhsArgs.NumArgs
thisArg = fcnInfo.RhsArgs.Arg( ii );
thisDataType = infoStruct.DataTypes.DataType( thisArg.DataTypeId );
if ( thisDataType.IsBus == 1 || thisDataType.IsStruct == 1 ) && strcmp( thisArg.Type, 'Parameter' )
fprintf( fid, '      /*\n' );
fprintf( fid, '       * Assign the Simulink Structure %s to Legacy Structure __%sBUS\n',  ...
thisArg.Identifier, thisArg.Identifier );
fprintf( fid, '       */\n' );
fprintf( fid, '      %%assign dTypeId = LibBlockParameterDataTypeId(p%d)\n', thisArg.DataId );

thisData = legacycode.util.lct_pGetDataFromArg( infoStruct, thisArg );
if ( thisDataType.IsBus == 1 ) && ( thisData.Width == 1 ) && ( thisData.IsComplex == 0 )

fprintf( fid, '      %%<SLibAssignSLStructToUserStruct(dTypeId, "(*(%s *)__%sBUS)", "(char *)%s", 0)>\n',  ...
thisDataType.DTName, thisArg.Identifier, thisArg.Identifier );
else 

fprintf( fid, '      %%assign width = LibBlockParameterWidth(p%d)\n', thisArg.DataId );
fprintf( fid, '      %%assign optStar = ISEQUAL(width,1) ? "*" : ""\n' );
fprintf( fid, '      %%assign isCmplx = LibBlockParameterIsComplex(p%d)\n', thisArg.DataId );
fprintf( fid, '      %%<SLibAssignSLStructToUserStructND(dTypeId, width, "(%%<optStar>(%s *)__%sBUS)", "(char *)%s", Matrix(1,1) [0], 0, isCmplx)>\n',  ...
thisDataType.DTName, thisArg.Identifier, thisArg.Identifier );
end 

fprintf( fid, '\n' );
end 
end 

% Decoded using De-pcode utility v1.2 from file /tmp/tmpWBS9As.p.
% Please follow local copyright laws when handling this file.

