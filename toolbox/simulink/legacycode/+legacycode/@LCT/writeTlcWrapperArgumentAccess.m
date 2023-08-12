function localParam = writeTlcWrapperArgumentAccess( h, fid, infoStruct, fcnStruct )







localParam = {  };

for ii = 1:fcnStruct.RhsArgs.NumArgs
thisArg = fcnStruct.RhsArgs.Arg( ii );
thisDataType = infoStruct.DataTypes.DataType( thisArg.DataTypeId );

if strcmp( thisArg.Type, 'Parameter' )

addrTaken = true;

if ( thisDataType.IsBus == 1 || thisDataType.IsStruct == 1 )
fprintf( fid,  ...
'    %%assign p%d_ptr = LibBlockParameterBaseAddr(p%d)\n',  ...
thisArg.DataId, thisArg.DataId );


thisData = legacycode.util.lct_pGetDataFromArg( infoStruct, thisArg );
thisPWorkNumber = infoStruct.DWorks.NumPWorks + thisData.BusInfo.DWorkId - 1;
fprintf( fid,  ...
'    %%assign p%dBUS_ptr = LibBlockPWork("", "", "", %d)\n',  ...
thisArg.DataId, thisPWorkNumber );

elseif ( ( thisDataType.Id ~= thisDataType.IdAliasedThruTo ) && ( thisDataType.IdAliasedTo ~=  - 1 ) ) ||  ...
thisDataType.IsEnum
if ~strcmp( thisArg.AccessType, 'direct' )
fprintf( fid,  ...
'    %%assign p%d_ptr = LibBlockParameterBaseAddr(p%d)\n',  ...
thisArg.DataId, thisArg.DataId );

else 



fprintf( fid,  ...
'    %%assign p%d_val = LibBlockParameter(p%d, "", "", 0)\n',  ...
thisArg.DataId, thisArg.DataId );




baseType = infoStruct.DataTypes.DataType( thisDataType.IdAliasedThruTo );
if baseType.IsBus || baseType.IsStruct



localParam{ end  + 1 } = sprintf(  ...
'%%<LibBlockParameterDataTypeName(p%d, "")> p%d_val = %%<p%d_val>',  ...
thisArg.DataId, thisArg.DataId, thisArg.DataId );%#ok<AGROW>   
else 



localParam{ end  + 1 } = sprintf(  ...
'%s p%d_val = (%s)%%<p%d_val>',  ...
baseType.NativeType, thisArg.DataId, baseType.NativeType, thisArg.DataId );%#ok<AGROW>
end 

addrTaken = false;
end 
else 
if strcmp( thisArg.AccessType, 'direct' )
fprintf( fid,  ...
'    %%assign p%d_val = LibBlockParameter(p%d, "", "", 0)\n',  ...
thisArg.DataId, thisArg.DataId );

addrTaken = false;

else 
fprintf( fid,  ...
'    %%assign p%d_ptr = LibBlockParameterBaseAddr(p%d)\n',  ...
thisArg.DataId, thisArg.DataId );
end 
end 

thisData = infoStruct.( [ thisArg.Type, 's' ] ).( thisArg.Type )( thisArg.DataId );
if thisData.CMatrix2D.DWorkId > 0

fprintf( fid,  ...
'    %%assign p%dM2D_ptr = LibBlockDWorkAddr(p%dM2D, "", "", 0)\n',  ...
thisArg.DataId, thisArg.DataId );




if addrTaken == false
fprintf( fid,  ...
'    %%assign p%d_ptr = LibBlockParameterBaseAddr(p%d)\n',  ...
thisArg.DataId, thisArg.DataId );
end 
end 
end 
end 



for ii = 1:fcnStruct.RhsArgs.NumArgs
thisArg = fcnStruct.RhsArgs.Arg( ii );
thisDataType = infoStruct.DataTypes.DataType( thisArg.DataTypeId );

if strcmp( thisArg.Type, 'Input' )

addrTaken = true;

if ( thisDataType.IsBus == 1 || thisDataType.IsStruct == 1 )
fprintf( fid,  ...
'    %%assign u%d_ptr = LibBlockInputSignalAddr(%d, "", "", 0)\n',  ...
thisArg.DataId, thisArg.DataId - 1 );


thisData = legacycode.util.lct_pGetDataFromArg( infoStruct, thisArg );
thisPWorkNumber = infoStruct.DWorks.NumPWorks + thisData.BusInfo.DWorkId - 1;
fprintf( fid,  ...
'    %%assign u%dBUS_ptr = LibBlockPWork("", "", "", %d)\n',  ...
thisArg.DataId, thisPWorkNumber );

elseif ( thisDataType.Id ~= thisDataType.IdAliasedThruTo ) && ( thisDataType.IdAliasedTo ~=  - 1 ) ||  ...
thisDataType.IsEnum
fprintf( fid,  ...
'    %%assign u%d_ptr = LibBlockInputSignalAddr(%d, "", "", 0)\n',  ...
thisArg.DataId, thisArg.DataId - 1 );
else 
if strcmp( thisArg.AccessType, 'direct' )
fprintf( fid,  ...
'    %%assign u%d_val = LibBlockInputSignal(%d, "", "", 0)\n',  ...
thisArg.DataId, thisArg.DataId - 1 );

addrTaken = false;

else 
fprintf( fid,  ...
'    %%assign u%d_ptr = LibBlockInputSignalAddr(%d, "", "", 0)\n',  ...
thisArg.DataId, thisArg.DataId - 1 );
end 
end 

thisData = infoStruct.( [ thisArg.Type, 's' ] ).( thisArg.Type )( thisArg.DataId );
if thisData.CMatrix2D.DWorkId > 0

fprintf( fid,  ...
'    %%assign u%dM2D_ptr = LibBlockDWorkAddr(u%dM2D, "", "", 0)\n',  ...
thisArg.DataId, thisArg.DataId );




if addrTaken == false
fprintf( fid,  ...
'    %%assign u%d_ptr = LibBlockInputSignalAddr(%d, "", "", 0)\n',  ...
thisArg.DataId, thisArg.DataId );
end 
end 
end 
end 



for ii = 1:fcnStruct.RhsArgs.NumArgs
thisArg = fcnStruct.RhsArgs.Arg( ii );
thisDataType = infoStruct.DataTypes.DataType( thisArg.DataTypeId );
if strcmp( thisArg.Type, 'Output' )

addrTaken = true;

if ( thisDataType.IsBus == 1 || thisDataType.IsStruct == 1 )
fprintf( fid,  ...
'    %%assign y%d_ptr = LibBlockOutputSignalAddr(%d, "", "", 0)\n',  ...
thisArg.DataId, thisArg.DataId - 1 );


thisData = legacycode.util.lct_pGetDataFromArg( infoStruct, thisArg );
thisPWorkNumber = infoStruct.DWorks.NumPWorks + thisData.BusInfo.DWorkId - 1;
fprintf( fid,  ...
'    %%assign y%dBUS_ptr = LibBlockPWork("", "", "", %d)\n',  ...
thisArg.DataId, thisPWorkNumber );

elseif ( thisDataType.Id ~= thisDataType.IdAliasedThruTo ) && ( thisDataType.IdAliasedTo ~=  - 1 ) ||  ...
thisDataType.IsEnum
fprintf( fid,  ...
'    %%assign y%d_ptr = LibBlockOutputSignalAddr(%d, "", "", 0)\n',  ...
thisArg.DataId, thisArg.DataId - 1 );

else 

if strcmp( thisArg.AccessType, 'direct' )
fprintf( fid,  ...
'    %%assign y%d_val = LibBlockOutputSignal(%d, "", "", 0)\n',  ...
thisArg.DataId, thisArg.DataId - 1 );

addrTaken = false;

else 
fprintf( fid,  ...
'    %%assign y%d_ptr = LibBlockOutputSignalAddr(%d, "", "", 0)\n',  ...
thisArg.DataId, thisArg.DataId - 1 );
end 
end 

thisData = infoStruct.( [ thisArg.Type, 's' ] ).( thisArg.Type )( thisArg.DataId );
if thisData.CMatrix2D.DWorkId > 0

fprintf( fid,  ...
'    %%assign y%dM2D_ptr = LibBlockDWorkAddr(y%dM2D, "", "", 0)\n',  ...
thisArg.DataId, thisArg.DataId );




if addrTaken == false
fprintf( fid,  ...
'    %%assign y%d_ptr = LibBlockOutputSignalAddr(%d, "", "", 0)\n',  ...
thisArg.DataId, thisArg.DataId );
end 
end 

end 
end 



for ii = 1:fcnStruct.RhsArgs.NumArgs
thisArg = fcnStruct.RhsArgs.Arg( ii );
thisDataType = infoStruct.DataTypes.DataType( thisArg.DataTypeId );
if strcmp( thisArg.Type, 'DWork' )
thisData = infoStruct.DWorks.DWork( thisArg.DataId );


if ~isempty( thisData.dwIdx )
if ( thisDataType.IsBus == 1 || thisDataType.IsStruct == 1 )
fprintf( fid,  ...
'    %%assign work%d_ptr = LibBlockDWorkAddr(work%d, "", "", 0)\n',  ...
thisArg.DataId, thisArg.DataId );


thisData = legacycode.util.lct_pGetDataFromArg( infoStruct, thisArg );
thisPWorkNumber = infoStruct.DWorks.NumPWorks + thisData.BusInfo.DWorkId - 1;
fprintf( fid,  ...
'    %%assign work%dBUS_ptr = LibBlockPWork("", "", "", %d)\n',  ...
thisArg.DataId, thisPWorkNumber );

elseif ( thisDataType.Id ~= thisDataType.IdAliasedThruTo ) && ( thisDataType.IdAliasedTo ~=  - 1 ) ||  ...
thisDataType.IsEnum
fprintf( fid,  ...
'    %%assign work%d_ptr = LibBlockDWorkAddr(work%d, "", "", 0)\n',  ...
thisArg.DataId, thisArg.DataId );

else 
if strcmp( thisArg.AccessType, 'direct' )
fprintf( fid,  ...
'    %%assign work%d_val = LibBlockDWork(work%d, "", "", 0)\n',  ...
thisArg.DataId, thisArg.DataId );

else 
fprintf( fid,  ...
'    %%assign work%d_ptr = LibBlockDWorkAddr(work%d, "", "", 0)\n',  ...
thisArg.DataId, thisArg.DataId );
end 
end 
else 
if strcmp( thisArg.AccessType, 'direct' )
fprintf( fid,  ...
'  %s%%assign work%d_val = LibBlockPWork("", "", "", %d)\n',  ...
infoStruct.INDENT_SPACE, thisArg.DataId, thisData.pwIdx - 1 );

else 
fprintf( fid,  ...
'  %s%%assign work%d_ptr = "&"+LibBlockPWork("", "", "", %d)\n',  ...
infoStruct.INDENT_SPACE, thisArg.DataId, thisData.pwIdx - 1 );
end 
end 
end 
end 


for ii = 1:fcnStruct.RhsArgs.NumArgs
thisArg = fcnStruct.RhsArgs.Arg( ii );
thisDataType = infoStruct.DataTypes.DataType( thisArg.DataTypeId );
if strcmp( thisArg.Type, 'SizeArg' )

impArgStr = h.generateTlcSizeArgString( infoStruct, thisArg );

fprintf( fid,  ...
'  %s%%assign %s_val = %s\n',  ...
infoStruct.INDENT_SPACE, thisArg.Identifier, impArgStr );

if ( ( thisDataType.Id ~= thisDataType.IdAliasedThruTo ) && ( thisDataType.IdAliasedTo ~=  - 1 ) )




dataType = infoStruct.DataTypes.DataType( thisDataType.IdAliasedThruTo );
localParam{ end  + 1 } = sprintf( '%s %s_val = %%<%s_val>',  ...
dataType.Name, thisArg.Identifier, thisArg.Identifier );%#ok<AGROW>
end 
end 
end 

if fcnStruct.LhsArgs.NumArgs == 1
thisArg = fcnStruct.LhsArgs.Arg( 1 );

thisDataType = infoStruct.DataTypes.DataType( thisArg.DataTypeId );

if strcmp( thisArg.Type, 'Output' )

fprintf( fid,  ...
'    %%assign y%d_ptr = LibBlockOutputSignalAddr(%d, "", "", 0)\n',  ...
thisArg.DataId, thisArg.DataId - 1 );

if ( thisDataType.IsBus == 1 || thisDataType.IsStruct == 1 )

thisData = legacycode.util.lct_pGetDataFromArg( infoStruct, thisArg );
thisPWorkNumber = infoStruct.DWorks.NumPWorks + thisData.BusInfo.DWorkId - 1;
fprintf( fid,  ...
'    %%assign y%dBUS_ptr = LibBlockPWork("", "", "", %d)\n',  ...
thisArg.DataId, thisPWorkNumber );
end 

thisData = infoStruct.( [ thisArg.Type, 's' ] ).( thisArg.Type )( thisArg.DataId );
if thisData.CMatrix2D.DWorkId > 0

fprintf( fid,  ...
'    %%assign y%dM2D_ptr = LibBlockDWorkAddr(y%dM2D, "", "", 0)\n',  ...
thisArg.DataId, thisArg.DataId );
end 

end 
end 



% Decoded using De-pcode utility v1.2 from file /tmp/tmp6SYuYb.p.
% Please follow local copyright laws when handling this file.

