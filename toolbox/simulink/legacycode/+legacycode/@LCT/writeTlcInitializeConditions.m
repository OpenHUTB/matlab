function writeTlcInitializeConditions( h, fid, infoStruct )




if infoStruct.Fcns.InitializeConditions.IsSpecified == 0
return 
end 

fprintf( fid, '%%%% Function: InitializeConditions  ========================================\n' );
fprintf( fid, '%%%%\n' );
fprintf( fid, '%%function InitializeConditions (block, system) Output\n' );
fprintf( fid, '  %%%%\n' );


if infoStruct.hasWrapper || infoStruct.isCPP
infoStruct.INDENT_SPACE = ' ';
h.writeUserDefinedHeaderIf( fid, infoStruct );



localVars = h.writeTlcWrapperArgumentAccess( fid, infoStruct, infoStruct.Fcns.InitializeConditions );
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
fprintf( fid, '    %s%s;\n', indentSpace, h.generateTlcFcnWrapperCallString( infoStruct, infoStruct.Fcns.InitializeConditions, 'initialize_conditions' ) );
if hasLocalVars
fprintf( fid, '    }\n' );
end 
fprintf( fid, '  %%else \n' );
end 



h.writeTlcArgumentAccess( fid, infoStruct, infoStruct.Fcns.InitializeConditions );
fprintf( fid, '  %s%%%%\n', infoStruct.INDENT_SPACE );



fprintf( fid, '    /* %%<Type> (%%<ParamSettings.FunctionName>): %%<Name> */\n' );
if infoStruct.has2DMatrix
fprintf( fid, '{\n' );
h.writeTlcTempVariableFor2DMatrix( fid, infoStruct, infoStruct.Fcns.InitializeConditions );
fprintf( fid, '\n' );
h.writeTlc2DMatrixConversion( fid, infoStruct, infoStruct.Fcns.InitializeConditions, true );
fprintf( fid, '\n' );
end 
fprintf( fid, '  %s%s;\n', infoStruct.INDENT_SPACE, h.generateTlcFcnCallString( infoStruct, infoStruct.Fcns.InitializeConditions ) );
if infoStruct.has2DMatrix
fprintf( fid, '\n' );
h.writeTlc2DMatrixConversion( fid, infoStruct, infoStruct.Fcns.InitializeConditions, false );
fprintf( fid, '\n}\n' );
end 


if infoStruct.hasWrapper || infoStruct.isCPP
fprintf( fid, '  %%endif \n' );
end 

fprintf( fid, '  %%%%\n' );
fprintf( fid, '%%endfunction\n' );
fprintf( fid, '\n' );

% Decoded using De-pcode utility v1.2 from file /tmp/tmpumXmbb.p.
% Please follow local copyright laws when handling this file.

