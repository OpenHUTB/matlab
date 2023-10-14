function kvp = createKeyValuePair( mfzModel, key, value )
arguments
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


