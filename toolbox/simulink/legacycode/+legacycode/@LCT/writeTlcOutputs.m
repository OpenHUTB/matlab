function writeTlcOutputs( h, fid, infoStruct )




if infoStruct.Fcns.Output.IsSpecified == 0
return 
end 

fprintf( fid, '%%%% Function: Outputs ======================================================\n' );
fprintf( fid, '%%%%\n' );
fprintf( fid, '%%function Outputs(block, system) Output\n' );
fprintf( fid, '  %%%%\n' );







hasExprInRtw = ( infoStruct.Fcns.Output.LhsArgs.NumArgs ~= 0 ) &&  ...
( infoStruct.Outputs.Num <= 1 ) &&  ...
( infoStruct.has2DMatrix == false );




if infoStruct.hasWrapper || infoStruct.isCPP
infoStruct.INDENT_SPACE = '  ';
h.writeUserDefinedHeaderIf( fid, infoStruct );



localVars = h.writeTlcWrapperArgumentAccess( fid, infoStruct, infoStruct.Fcns.Output );

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
fprintf( fid, '    %s%s;\n', indentSpace, h.generateTlcFcnWrapperCallString( infoStruct, infoStruct.Fcns.Output, 'output' ) );
if hasLocalVars
fprintf( fid, '    }\n' );
end 
fprintf( fid, '  %%else \n' );
end 

if hasExprInRtw == true






thisOutputNumber = infoStruct.Fcns.Output.LhsArgs.Arg( 1 ).DataId;

fprintf( fid, '    %%if !LibBlockOutputSignalIsExpr(%d)\n', thisOutputNumber - 1 );
infoStruct.INDENT_SPACE = [ infoStruct.INDENT_SPACE, '  ' ];
end 



h.writeTlcArgumentAccess( fid, infoStruct, infoStruct.Fcns.Output );

fprintf( fid, '  %s%%%%\n', infoStruct.INDENT_SPACE );

if infoStruct.has2DMatrix
fprintf( fid, '{\n' );
h.writeTlcTempVariableFor2DMatrix( fid, infoStruct, infoStruct.Fcns.Output );
fprintf( fid, '\n' );
h.writeTlc2DMatrixConversion( fid, infoStruct, infoStruct.Fcns.Output, true );
fprintf( fid, '\n' );
end 
fprintf( fid, '  %s%s;\n', infoStruct.INDENT_SPACE, h.generateTlcFcnCallString( infoStruct, infoStruct.Fcns.Output, 0 ) );
if infoStruct.has2DMatrix
fprintf( fid, '\n' );
h.writeTlc2DMatrixConversion( fid, infoStruct, infoStruct.Fcns.Output, false );
fprintf( fid, '\n}\n' );
end 

if hasExprInRtw == true
fprintf( fid, '    %%endif \n' );
end 


if infoStruct.hasWrapper || infoStruct.isCPP
fprintf( fid, '  %%endif \n' );
end 

fprintf( fid, '  %%%%\n' );
fprintf( fid, '%%endfunction\n' );
fprintf( fid, '\n' );

% Decoded using De-pcode utility v1.2 from file /tmp/tmpBWRP4e.p.
% Please follow local copyright laws when handling this file.

