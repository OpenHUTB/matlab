function writeTlcBlockInstanceSetup( h, fid, infoStruct )




fprintf( fid, '%%%% Function: BlockInstanceSetup ===========================================\n' );
fprintf( fid, '%%%%\n' );
fprintf( fid, '%%function BlockInstanceSetup(block, system) void\n' );
fprintf( fid, '  %%%%\n' );



if infoStruct.hasWrapper || infoStruct.isCPP
infoStruct.INDENT_SPACE = '  ';
h.writeUserDefinedHeaderIf( fid, infoStruct );

fprintf( fid, '  %%else\n' );
end 

fprintf( fid, '  %s%%<LibBlockSetIsExpressionCompliant(block)>\n', infoStruct.INDENT_SPACE );


if infoStruct.hasWrapper || infoStruct.isCPP
fprintf( fid, '  %%endif\n' );
end 

fprintf( fid, '  %%%%\n' );
fprintf( fid, '%%endfunction\n' );
fprintf( fid, '\n' );

% Decoded using De-pcode utility v1.2 from file /tmp/tmp3SNl9u.p.
% Please follow local copyright laws when handling this file.

