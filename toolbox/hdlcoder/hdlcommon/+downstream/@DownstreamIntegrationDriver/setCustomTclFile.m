function setCustomTclFile( obj, value )



msg = message( 'HDLShared:hdldialog:HDLWAInputAdditionalTclFiles' ).getString;
downstream.tool.checkNonASCII( value, msg );

obj.hToolDriver.setCustomTclFile( value );

end 

% Decoded using De-pcode utility v1.2 from file /tmp/tmpqvQBA6.p.
% Please follow local copyright laws when handling this file.

