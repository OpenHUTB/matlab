function parameter_value_changed_cb( dlgH, source, tag, value )





if ( startsWith( value, '=' ) )

value( value == ' ' ) = '';
value = strip( value, 'left', '=' );
source.Value = slexpr( value );
else 
source.Value = value;
end 

end 


% Decoded using De-pcode utility v1.2 from file /tmp/tmpgH7yKK.p.
% Please follow local copyright laws when handling this file.

