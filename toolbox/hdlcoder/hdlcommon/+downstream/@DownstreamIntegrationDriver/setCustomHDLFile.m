function setCustomHDLFile( obj, value )




msg = message( 'HDLShared:hdldialog:HDLWAInputAdditionalSourceFiles' ).getString;
downstream.tool.checkNonASCII( value, msg );

obj.hToolDriver.setCustomHDLFile( value );
obj.saveCustomFileSettingToModel( obj.hCodeGen.ModelName, obj.getCustomSourceFile );
end 

% Decoded using De-pcode utility v1.2 from file /tmp/tmpfg8zf0.p.
% Please follow local copyright laws when handling this file.

