function v = validateBusIncompatible( this, hC )%#ok<INUSL>




v = hdlvalidatestruct(  );


for itr = 1:length( hC.PirInputSignals )
type = hC.PirInputSignals( itr ).Type;
if type.isRecordType
v = HDLMathlibBlockCheck( hC );
return ;
end 
end 

for itr = 1:length( hC.PirOutputSignals )
type = hC.PirOutputSignals( itr ).Type;
if type.isRecordType
v = HDLMathlibBlockCheck( hC );
return ;
end 
end 
end 





function v = HDLMathlibBlockCheck( hC )
v = hdlvalidatestruct(  );
if ~ishandle( hC.SimulinkHandle )
return ;
end 
blkPath = hC.Name;
try 
blkPath = getfullname( hC.SimulinkHandle );
catch mEx %#ok<NASGU>
end 

reflibblk = get_param( hC.SimulinkHandle, 'ReferenceBlock' );
if ~isempty( reflibblk ) && strncmp( reflibblk, 'HDLMathLib', 9 )
v = hdlvalidatestruct( 1, message( 'hdlcoder:validate:UnsupportedBusTypeForMathlibBlocks', blkPath ) );
return ;
end 
end 

% Decoded using De-pcode utility v1.2 from file /tmp/tmpWdMBkJ.p.
% Please follow local copyright laws when handling this file.

