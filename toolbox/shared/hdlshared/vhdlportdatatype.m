function vhdltype = vhdlportdatatype( dt )






switch dt
case 'single'
if ~isTargetFloatingPointMode(  )
warning( message( 'HDLShared:directemit:singletodouble' ) );
end 
vhdltype = 'real';
otherwise 
vhdltype = vhdlgetvtype( dt );
end 


vhdltype = strrep( vhdltype, 'unsigned(', 'std_logic_vector(' );
vhdltype = strrep( vhdltype, 'signed(', 'std_logic_vector(' );







% Decoded using De-pcode utility v1.2 from file /tmp/tmp4GeTg5.p.
% Please follow local copyright laws when handling this file.

