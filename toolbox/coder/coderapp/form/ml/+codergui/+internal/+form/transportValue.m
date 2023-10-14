function transportable = transportValue( transporter, value )
arguments
    transporter( 1, 1 )codergui.internal.form.model.TransportableValue
    value
end

transportable = true;
if coderapp.internal.util.isScalarText( value )
    transporter.StringValue = value;
elseif isscalar( value )
    if isinteger( value )
        transporter.IntValue = value;
    elseif isnumeric( value )
        transporter.DoubleValue = value;
    elseif islogical( value )
        transporter.BooleanValue = value;
    else
        transportable = false;
    end
else
    transportable = false;
end
end


