function refreshToolList( obj )



previousToolEmpty = obj.hAvailableToolList.isToolListEmpty;
obj.hAvailableToolList.buildAvailableToolList;
synToolNameList = obj.hAvailableToolList.getToolNameList;
qproExist = 0;


for ii = 1:length( synToolNameList )
if strcmpi( synToolNameList{ ii }, 'Intel Quartus Pro' )
qproExist = 1;
end 
end 
if ( previousToolEmpty ) || qproExist
obj.set( 'Tool', obj.getInitToolStr );
else 

toolName = obj.get( 'Tool' );



obj.setToolName( toolName );
end 

end 



% Decoded using De-pcode utility v1.2 from file /tmp/tmpD2HSlz.p.
% Please follow local copyright laws when handling this file.

