function numStr = convertNumber2String( value )

arguments
    value{ mustBeNumeric }
end

if ( value >= 1e-2 && value < 1e3 )
    residule = abs( value - round( value ) );

    if ( residule > eps && residule < 1e-4 )
        numStr = num2str( value, '%0.4f' );
    else
        numStr = num2str( value );
    end
else
    numStr = num2str( value, '%0.4e' );
end
end
