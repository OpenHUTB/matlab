function unitType = getUnitAbbreviation( str )



R36
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
% Decoded using De-pcode utility v1.2 from file /tmp/tmpj18Lgj.p.
% Please follow local copyright laws when handling this file.

