classdef Property < matlabshared.devicetree.property.PropertyBase


properties ( SetAccess = protected )

Value












Type matlabshared.devicetree.property.PropertyType
end 

methods 
function obj = Property( name, value )
R36
name
end 


R36( Repeating )
value
end 

obj = obj@matlabshared.devicetree.property.PropertyBase( name );


switch length( value )
case 0




type = matlabshared.devicetree.property.PropertyType.empty;
case 1






value = value{ : };
type = obj.getPropertyTypeFromValue( value );
otherwise 


type = matlabshared.devicetree.property.PropertyType.Mixed;
for ii = 1:length( value )


obj.getPropertyTypeFromValue( value{ ii } );
end 
end 

obj.Value = value;
obj.Type = type;
end 
end 


methods ( Access = protected )
function printBody( obj, hDTPrinter, ~, ~ )




propLine = obj.Name;
if ~obj.isEmptyProperty
propLine = propLine + " = " + obj.getPropertyValueText;
end 
propLine = propLine + ";";
hDTPrinter.addLine( propLine );
end 

function propText = getPropertyValueText( obj, value, type )










if nargin < 2
value = obj.Value;
end 
if nargin < 3
type = obj.Type;
end 

if obj.isEmptyProperty( type )
error( message( 'devicetree:base:NoTextForEmptyProperty', obj.Name ) );
end 





switch type
case "String"








value = string( value );
propText = """" + join( value( : ), """, """ ) + """";
case "Bytestring"

propList = string( dec2hex( value ) );
propListStr = join( propList( : ), "" );


propListStr = obj.formatByteString( propListStr );
propText = "[" + propListStr + "]";
case "Cell"
propList = strings( size( value ) );
for ii = 1:length( value )
val = value{ ii };
if isnumeric( val )


valStr = "0x" + string( dec2hex( val ) );
else 

valStr = val;
end 
propList( ii ) = valStr;
end 

propListStr = join( propList( : ), " " );
propText = "<" + propListStr + ">";
case "Mixed"
mixedText = strings( size( value ) );
for ii = 1:length( mixedText )
val = value{ ii };
mixedText( ii ) = obj.getPropertyValueText( val, obj.getPropertyTypeFromValue( val ) );
end 
propText = join( mixedText, ", " );
end 
end 

function isEmpty = isEmptyProperty( obj, type )

if nargin < 2
type = obj.Type;
end 

isEmpty = isequal( type, matlabshared.devicetree.property.PropertyType.empty );
end 
end 


methods ( Static, Access = protected )
function type = getPropertyTypeFromValue( value )






if ~iscell( value )



value = convertCharsToStrings( value );
end 

if isstring( value )
type = matlabshared.devicetree.property.PropertyType.String;
elseif isnumeric( value )
type = matlabshared.devicetree.property.PropertyType.Bytestring;
elseif iscell( value )


isNumeric = cellfun( @isnumeric, value );
isReference = cellfun( @( x )( ischar( x ) || isstring( x ) ) && startsWith( x, "&" ), value );
if ~all( isNumeric | isReference )
error( message( 'devicetree:base:InvalidCellProperty' ) );
end 

type = matlabshared.devicetree.property.PropertyType.Cell;
else 
error( message( 'devicetree:base:InvalidPropertyValue' ) );
end 
end 

function validateInferredPropertyType( value, type )







inferredType = matlabshared.devicetree.property.Property.getPropertyTypeFromValue( value );
if inferredType ~= type
error( message( 'devicetree:base:InvalidPropertyTypeInferred', type, inferredType ) );
end 
end 

function byteStr = formatByteString( hexStr )





if mod( strlength( hexStr ), 2 )
hexStr = "0" + hexStr;
end 


numBytes = strlength( hexStr ) / 2;
bytes = strings( 1, numBytes );
for ii = 1:numBytes
bytes( ii ) = extractBetween( hexStr, 2 * ii - 1, 2 * ii );
end 


byteStr = join( bytes, " " );
end 
end 
end 
% Decoded using De-pcode utility v1.2 from file /tmp/tmplz1fR7.p.
% Please follow local copyright laws when handling this file.

