function unitType = getUnitAbbreviation( str )

arguments
    str string
end

switch lower( str )
    case { "in", "inches", "inch" }
        unitType = "in";
    case { "cm", "centimeters", "centimeter" }
        unitType = "cm";
    case { "mm", "millimeters", "millimeter" }
        unitType = "mm";
    case { "pt", "points", "point" }
        unitType = "pt";
    case { "px", "pixels", "pixel" }
        unitType = "px";
    case { "pi", "picas", "pica", "pc" }
        unitType = "pc";
    otherwise
        unitType = "px";
end
end

