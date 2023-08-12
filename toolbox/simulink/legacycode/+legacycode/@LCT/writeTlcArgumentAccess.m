function writeTlcArgumentAccess( h, fid, infoStruct, fcnStruct, isBlockOutputSignal )





if nargin < 5
isBlockOutputSignal = false;
end 



for ii = 1:fcnStruct.RhsArgs.NumArgs
thisArg = fcnStruct.RhsArgs.Arg( ii );
if strcmp( thisArg.Type, 'Parameter' )
if strcmp( thisArg.AccessType, 'direct' )
fprintf( fid,  ...
'  %s%%assign p%d_val = LibBlockParameter(p%d, "", "", 0)\n',  ...
infoStruct.INDENT_SPACE, thisArg.DataId, thisArg.DataId );
else 
fprintf( fid,  ...
'  %s%%assign p%d_ptr = LibBlockParameterBaseAddr(p%d)\n',  ...
infoStruct.INDENT_SPACE, thisArg.DataId, thisArg.DataId );
end 
end 
end 



for ii = 1:fcnStruct.RhsArgs.NumArgs
thisArg = fcnStruct.RhsArgs.Arg( ii );
if strcmp( thisArg.Type, 'Input' )
if strcmp( thisArg.AccessType, 'direct' )
fprintf( fid,  ...
'  %s%%assign u%d_val = LibBlockInputSignal(%d, "", "", 0)\n',  ...
infoStruct.INDENT_SPACE, thisArg.DataId, thisArg.DataId - 1 );
else 
fprintf( fid,  ...
'  %s%%assign u%d_ptr = LibBlockInputSignalAddr(%d, "", "", 0)\n',  ...
infoStruct.INDENT_SPACE, thisArg.DataId, thisArg.DataId - 1 );
end 
end 
end 



for ii = 1:fcnStruct.RhsArgs.NumArgs
thisArg = fcnStruct.RhsArgs.Arg( ii );
if strcmp( thisArg.Type, 'Output' )
if strcmp( thisArg.AccessType, 'direct' )
fprintf( fid,  ...
'  %s%%assign y%d_val = LibBlockOutputSignal(%d, "", "", 0)\n',  ...
infoStruct.INDENT_SPACE, thisArg.DataId, thisArg.DataId - 1 );
else 
fprintf( fid,  ...
'  %s%%assign y%d_ptr = LibBlockOutputSignalAddr(%d, "", "", 0)\n',  ...
infoStruct.INDENT_SPACE, thisArg.DataId, thisArg.DataId - 1 );
end 
end 
end 



for ii = 1:fcnStruct.RhsArgs.NumArgs
thisArg = fcnStruct.RhsArgs.Arg( ii );
if strcmp( thisArg.Type, 'DWork' )
thisData = infoStruct.DWorks.DWork( thisArg.DataId );


if ~isempty( thisData.dwIdx )
if strcmp( thisArg.AccessType, 'direct' )
fprintf( fid,  ...
'  %s%%assign work%d_val = LibBlockDWork(work%d, "", "", 0)\n',  ...
infoStruct.INDENT_SPACE, thisArg.DataId, thisArg.DataId );

else 
fprintf( fid,  ...
'  %s%%assign work%d_ptr = LibBlockDWorkAddr(work%d, "", "", 0)\n',  ...
infoStruct.INDENT_SPACE, thisArg.DataId, thisArg.DataId );
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
if strcmp( thisArg.Type, 'SizeArg' )

impArgStr = h.generateTlcSizeArgString( infoStruct, thisArg );

fprintf( fid,  ...
'  %s%%assign %s_val = %s\n',  ...
infoStruct.INDENT_SPACE, thisArg.Identifier, impArgStr );

end 
end 





if fcnStruct.LhsArgs.NumArgs == 1 && ~isBlockOutputSignal
thisArg = fcnStruct.LhsArgs.Arg( 1 );
if strcmp( thisArg.Type, 'Output' )
if strcmp( thisArg.AccessType, 'direct' )
fprintf( fid,  ...
'  %s%%assign y%d_val = LibBlockOutputSignal(%d, "", "", 0)\n',  ...
infoStruct.INDENT_SPACE, thisArg.DataId, thisArg.DataId - 1 );
else 
fprintf( fid,  ...
'  %s%%assign y%d_ptr = LibBlockOutputSignalAddr(%d, "", "", 0)\n',  ...
infoStruct.INDENT_SPACE, thisArg.DataId, thisArg.DataId - 1 );
end 
end 
end 



% Decoded using De-pcode utility v1.2 from file /tmp/tmp3vUuz0.p.
% Please follow local copyright laws when handling this file.

