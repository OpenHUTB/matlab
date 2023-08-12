function refreshKeysReplacedAndNotReplacedBlkTables( obj )




entries = obj.ReplacedBlocksTable.keys;
for idx = 1:length( entries )
repInfo = obj.ReplacedBlocksTable( entries{ idx } );
blockH = get_param( repInfo.ReplacementFullPath, 'Handle' );
obj.ReplacedBlocksTable.remove( entries{ idx } );
obj.ReplacedBlocksTable( blockH ) = repInfo;
end 

entries = obj.NotReplacedBlocksTable.keys;
for idx = 1:length( entries )
repInfo = obj.NotReplacedBlocksTable( entries{ idx } );
blockH = get_param( repInfo.BeforeRepFullPath, 'Handle' );
obj.NotReplacedBlocksTable.remove( entries{ idx } );
obj.NotReplacedBlocksTable( blockH ) = repInfo;
end 
end 


% Decoded using De-pcode utility v1.2 from file /tmp/tmpzsNdr6.p.
% Please follow local copyright laws when handling this file.

