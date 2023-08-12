function [ SBSigSuite, modified ] = update_sbobj_fields( savedUD )




modified = 0;
SBSigSuite = savedUD.sbobj;
emptyIdx = ~cellfun( 'isempty', { SBSigSuite.Groups.Name } );
if ( ~all( emptyIdx ) ||  ...
strcmp( SBSigSuite.Groups( 1 ).Name, 'default' ) )
grpNames = { savedUD.dataSet.name };
sigNames = { savedUD.channels.label };
grpCnt = length( grpNames );
sigCnt = length( sigNames );
SBSigSuite.groupRename( 1:grpCnt, grpNames );
SBSigSuite.groupSignalRename( 1:sigCnt, sigNames, 0 );
modified = 1;
else 
emptyIdx = ~cellfun( 'isempty', { SBSigSuite.Groups( 1 ).Signals.Name } );
if ( ~all( emptyIdx ) )
sigNames = { savedUD.channels.label };
sigCnt = length( sigNames );
SBSigSuite.groupSignalRename( 1:sigCnt, sigNames, 0 );
modified = 1;
end 
end 

end 


% Decoded using De-pcode utility v1.2 from file /tmp/tmpekzG6C.p.
% Please follow local copyright laws when handling this file.

