function writeTlcFcnGenerateUniqueFileName( h, fid, infoStruct )%#ok<INUSL>






if ~( infoStruct.hasWrapper || infoStruct.isCPP )
return 
end 

fprintf( fid, '%%%% Function: FcnGenerateUniqueFileName ====================================\n' );
fprintf( fid, '%%%%\n' );
fprintf( fid, '%%function FcnGenerateUniqueFileName(filename, type) void\n' );
fprintf( fid, '  %%%%\n' );
fprintf( fid, '  %%assign isReserved = TLC_FALSE\n' );
fprintf( fid, '  %%foreach idxFile = CompiledModel.DataObjectUsage.NumFiles[0]\n' );
fprintf( fid, '    %%assign thisFile = CompiledModel.DataObjectUsage.File[idxFile]\n' );
fprintf( fid, '    %%if (thisFile.Name==filename) && (thisFile.Type==type)\n' );
fprintf( fid, '      %%assign isReserved = TLC_TRUE\n' );
fprintf( fid, '      %%break\n' );
fprintf( fid, '    %%endif\n' );
fprintf( fid, '  %%endforeach\n' );
fprintf( fid, '  %%if (isReserved==TLC_TRUE)\n' );
fprintf( fid, '    %%assign filename = FcnGenerateUniqueFileName(filename + "_", type)\n' );
fprintf( fid, '  %%endif\n' );
fprintf( fid, '  %%return filename\n' );
fprintf( fid, '  %%%%\n' );
fprintf( fid, '%%endfunction\n' );
fprintf( fid, '\n' );

% Decoded using De-pcode utility v1.2 from file /tmp/tmpVONqPp.p.
% Please follow local copyright laws when handling this file.

