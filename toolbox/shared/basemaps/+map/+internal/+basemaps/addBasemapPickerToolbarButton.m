function addBasemapPickerToolbarButton( tb, NameValueArgs )








R36
tb matlab.ui.controls.AxesToolbar{ mustBeNonempty }


NameValueArgs.BasemapNames string{ mustBeVector, mustBeBasemapNames }
NameValueArgs.DisplayNames string{ mustBeVector }
NameValueArgs.BasemapIcons string{ mustBeVector, map.internal.basemaps.mustBeIcons }
NameValueArgs.NumColumns( 1, 1 )double{ mustBePositive, mustBeInteger }
end 

mustMatchLength( NameValueArgs )
try 
for k = 1:length( tb )
NameValueArgs.Toolbar = tb( k );
nameValueCell = namedargs2cell( NameValueArgs );
fig = ancestor( tb( k ), 'figure' );
picker = [  ];
picker = map.ui.control.internal.BasemapPicker( 'Parent', fig );
set( picker, nameValueCell{ : } );
end 
catch e
delete( picker )
if isempty( e.cause )
msg = e.message;
else 
msg = e.cause{ 1 }.message;
end 
exc = MException( e.identifier, msg );
throwAsCaller( exc )
end 
end 


function mustBeBasemapNames( value )


if strlength( value ) > 0
mustBeMember( value,  ...
[ matlab.graphics.chart.internal.maps.basemapNames;"none" ] )
end 
end 

function mustMatchLength( NameValueArgs )




if isfield( NameValueArgs, "NumColumns" )
NameValueArgs = rmfield( NameValueArgs, "NumColumns" );
end 

fnames = fieldnames( NameValueArgs );
if ~isempty( NameValueArgs ) && length( fnames ) > 1
expNumel = [  ];
for k = 1:length( fnames )
name = fnames{ k };
value = NameValueArgs.( name );
if strlength( value ) > 0
if isempty( expNumel )
expNumel = numel( value );
name1 = name;
end 
if numel( value ) ~= expNumel
error( message( 'shared_basemaps:BasemapPicker:LengthMismatch', name, name1 ) )
end 
end 
end 
end 
end 

% Decoded using De-pcode utility v1.2 from file /tmp/tmp69b30b.p.
% Please follow local copyright laws when handling this file.

