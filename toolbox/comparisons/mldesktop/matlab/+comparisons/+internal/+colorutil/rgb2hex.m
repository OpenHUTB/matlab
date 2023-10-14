function hex = rgb2hex( rgb )

arguments
    rgb{ comparisons.internal.colorutil.mustBeValidRGB }
end

hex = arrayfun( @( x )dec2hex( x, 2 ), rgb, 'UniformOutput', false );
hex = [ '#', lower( [ hex{ : } ] ) ];
end


