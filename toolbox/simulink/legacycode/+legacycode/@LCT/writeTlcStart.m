function writeTlcStart( h, fid, infoStruct )







if infoStruct.Fcns.Start.IsSpecified == 0 && infoStruct.DWorks.NumDWorkForBus == 0
return 
end 

fprintf( fid, '%%%% Function: Start ========================================================\n' );
fprintf( fid, '%%%%\n' );
fprintf( fid, '%%function Start(block, system) Output\n' );
fprintf( fid, '  %%%%\n' );

if infoStruct.Fcns.Start.IsSpecified == 0



infoStruct.INDENT_SPACE = '  ';
h.writeUserDefinedHeaderIf( fid, infoStruct );


iWritePWorkAllocMemCall( fid, infoStruct );


fprintf( fid, '  %%endif \n' );

else 


if infoStruct.hasWrapper || infoStruct.isCPP
infoStruct.INDENT_SPACE = '  ';
h.writeUserDefinedHeaderIf( fid, infoStruct );


iWritePWorkAllocMemCall( fid, infoStruct );



localVars = h.writeTlcWrapperArgumentAccess( fid, infoStruct, infoStruct.Fcns.Start );
hasLocalVars = ~isempty( localVars );

fprintf( fid, '    %%%%\n' );
fprintf( fid, '    /* %%<Type> (%%<ParamSettings.FunctionName>): %%<Name> */\n' );
indentSpace = '';
if hasLocalVars


indentSpace = '  ';
fprintf( fid, '    {\n' );
for ii = 1:length( localVars )
fprintf( fid, '      %s;\n', localVars{ ii } );
end 
end 
fprintf( fid, '    %s%s;\n', indentSpace, h.generateTlcFcnWrapperCallString( infoStruct, infoStruct.Fcns.Start, 'start' ) );
if hasLocalVars
fprintf( fid, '    }\n' );
end 
fprintf( fid, '  %%else \n' );
end 



h.writeTlcArgumentAccess( fid, infoStruct, infoStruct.Fcns.Start );
fprintf( fid, '  %s%%%%\n', infoStruct.INDENT_SPACE );



fprintf( fid, '    /* %%<Type> (%%<ParamSettings.FunctionName>): %%<Name> */\n' );
if infoStruct.has2DMatrix
fprintf( fid, '{\n' );
h.writeTlcTempVariableFor2DMatrix( fid, infoStruct, infoStruct.Fcns.Start );
fprintf( fid, '\n' );
h.writeTlc2DMatrixConversion( fid, infoStruct, infoStruct.Fcns.Start, true );
fprintf( fid, '\n' );
end 
fprintf( fid, '  %s%s;\n', infoStruct.INDENT_SPACE, h.generateTlcFcnCallString( infoStruct, infoStruct.Fcns.Start ) );
if infoStruct.has2DMatrix
fprintf( fid, '\n' );
h.writeTlc2DMatrixConversion( fid, infoStruct, infoStruct.Fcns.Start, false );
fprintf( fid, '\n}\n' );
end 


if infoStruct.hasWrapper || infoStruct.isCPP
fprintf( fid, '  %%endif \n' );
end 
end 

fprintf( fid, '  %%%%\n' );
fprintf( fid, '%%endfunction\n' );
fprintf( fid, '\n' );

end 


function iWritePWorkAllocMemCall( fid, infoStruct )

if infoStruct.DWorks.NumDWorkForBus < 1
return 
end 


pWorkForBusInfo = cell( infoStruct.DWorks.NumDWorkForBus, 2 );
for ii = 1:infoStruct.DWorks.NumDWorkForBus

thisDWork = infoStruct.DWorks.DWorkForBus( ii );

thisDWorkNumber = infoStruct.DWorks.NumPWorks + ii - 1;

varName = sprintf( '%sBUS_pAddr', thisDWork.Identifier );

pWorkForBusInfo{ ii, 1 } = varName;

switch thisDWork.BusInfo.Type
case 'Input'
pWorkForBusInfo{ ii, 2 } = sprintf( '%%<LibBlockInputSignalWidth(%d)>', thisDWork.BusInfo.DataId - 1 );

case 'Output'
pWorkForBusInfo{ ii, 2 } = sprintf( '%%<LibBlockOutputSignalWidth(%d)>', thisDWork.BusInfo.DataId - 1 );

case 'DWork'
pWorkForBusInfo{ ii, 2 } = sprintf( '%%<LibBlockDWorkWidth(work%d)>', thisDWork.BusInfo.DataId );

case 'Parameter'
pWorkForBusInfo{ ii, 2 } = sprintf( '%%<LibBlockParameterWidth(p%d)>', thisDWork.BusInfo.DataId );

otherwise 

end 
fprintf( fid, '    %%assign %s = "&" + LibBlockPWork("", "", "", %d)\n', varName, thisDWorkNumber );
end 


fprintf( fid, '    %%assign blockPath = STRING(LibGetBlockPath(block))\n' );
protoStr = sprintf( 'if (%s_wrapper_allocmem(', infoStruct.Specs.SFunctionName );
sep = '';
for ii = 1:size( pWorkForBusInfo, 1 )
protoStr = sprintf( '%s%s%%<%s>, %s', protoStr, sep,  ...
pWorkForBusInfo{ ii, 1 }, pWorkForBusInfo{ ii, 2 } );
sep = ', ';
end 

fprintf( fid, '    %s)!=0) %%<LibSetRTModelErrorStatus("\\"Memory allocation failure for %%<blockPath>\\"")>;\n\n', protoStr );

end 


% Decoded using De-pcode utility v1.2 from file /tmp/tmpyncKsd.p.
% Please follow local copyright laws when handling this file.

