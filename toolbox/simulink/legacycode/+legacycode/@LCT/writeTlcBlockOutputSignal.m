function writeTlcBlockOutputSignal( h, fid, infoStruct )









if ( infoStruct.Fcns.Output.LhsArgs.NumArgs == 0 ) ||  ...
( infoStruct.Fcns.Output.IsSpecified == 0 ) ||  ...
( infoStruct.Outputs.Num > 1 ) ||  ...
( infoStruct.has2DMatrix == true ) ...

return 
end 


thisOutputNumber = infoStruct.Fcns.Output.LhsArgs.Arg( 1 ).DataId;

fprintf( fid, '%%%% Function: BlockOutputSignal ============================================\n' );
fprintf( fid, '%%%%\n' );
fprintf( fid, '%%function BlockOutputSignal(block,system,portIdx,ucv,lcv,idx,retType) void\n' );
fprintf( fid, '  %%%%\n' );



h.writeTlcArgumentAccess( fid, infoStruct, infoStruct.Fcns.Output, true );

fprintf( fid, '  %%%%\n' );
fprintf( fid, '  %%switch retType\n' );
fprintf( fid, '    %%case "Signal"\n' );
fprintf( fid, '      %%if portIdx == %d\n', thisOutputNumber - 1 );
fprintf( fid, '        %%return "%s"\n', h.generateTlcFcnCallString( infoStruct, infoStruct.Fcns.Output, 1 ) );
fprintf( fid, '      %%else\n' );
fprintf( fid, '        %%assign errTxt = "Block output port index not supported: %%<portIdx>"\n' );
fprintf( fid, '        %%<LibBlockReportError(block,errTxt)>\n' );
fprintf( fid, '      %%endif\n' );
fprintf( fid, '    %%default\n' );
fprintf( fid, '      %%assign errTxt = "Unsupported return type: %%<retType>"\n' );
fprintf( fid, '      %%<LibBlockReportError(block,errTxt)>\n' );
fprintf( fid, '  %%endswitch\n' );
fprintf( fid, '  %%%%\n' );
fprintf( fid, '%%endfunction\n' );
fprintf( fid, '\n' );



% Decoded using De-pcode utility v1.2 from file /tmp/tmprQPIP9.p.
% Please follow local copyright laws when handling this file.

