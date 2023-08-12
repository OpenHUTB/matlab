

function kvp = createKeyValuePair( mfzModel, key, value )
R36
mfzModel( 1, 1 )mf.zero.Model
key( 1, : )char
value
end 

kvp = codergui.internal.form.model.KeyValuePair( mfzModel );
kvp.Key = key;
if ~codergui.internal.form.transportValue( kvp, value )
kvp = codergui.internal.form.model.KeyValuePair.empty(  );
end 
end 
% Decoded using De-pcode utility v1.2 from file /tmp/tmp01XnNy.p.
% Please follow local copyright laws when handling this file.

