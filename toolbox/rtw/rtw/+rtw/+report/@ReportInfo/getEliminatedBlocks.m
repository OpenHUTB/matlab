function reducedBlocks = getEliminatedBlocks( obj )



if obj.IsERTTarget
if strcmp( obj.Config.GenerateTraceInfo, 'on' )
reducedBlocks = obj.BlockTracker.getAllReducedBlocks( obj.BuildDirectory );
else 
DAStudio.error( 'RTW:report:ReducedBlocksModelToCodeOnly' );
end 
else 
DAStudio.error( 'RTW:report:ReducedBlocksERTOnly' );
end 
end 

% Decoded using De-pcode utility v1.2 from file /tmp/tmp5E_X48.p.
% Please follow local copyright laws when handling this file.

