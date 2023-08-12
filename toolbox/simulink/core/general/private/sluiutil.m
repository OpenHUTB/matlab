function y = sluiutil( varargin )




























y = feval( varargin{ 1 }, varargin{ 2:nargin } );

return 


function y = dimension( toplevel )



oldUnits = get( 0, 'Units' );

set( 0, 'Units', 'Pixels' );
screenSizePixels = get( 0, 'ScreenSize' );

set( 0, 'Units', 'Characters' );
screenSizeChars = get( 0, 'ScreenSize' );

set( 0, 'Units', oldUnits );

hScale = screenSizeChars( 3 ) / screenSizePixels( 3 );
vScale = screenSizeChars( 4 ) / screenSizePixels( 4 );

y.leftAlignment = 10 * hScale;
y.vertSpacer = 10 * vScale;

y.hScale = hScale;
y.vScale = vScale;





sys = i_sluigeom;
y.textHeight = 1 + max( [ sys.checkbox( 4 ), sys.edit( 4 ),  ...
sys.text( 4 ), sys.popupmenu( 4 ) ] );




y.buttonWidth = 100 * hScale;
y.buttonHeight = 1 + sys.pushbutton( 4 );

return 


function cellArray = getCellArrayFromCharArray( charArray )

cellArray = cell( 0 );
while ~isempty( charArray )
[ cellArray{ end  + 1 }, charArray ] = strtok( charArray, sprintf( '\n' ) );
end 

return 


function charArray = getCharArrayFromCellArray( cellArray )


if isempty( cellArray )
charArray = '';
elseif ischar( cellArray )
charArray = cellArray;
else 

cellArray( :, 2 ) = { sprintf( '\n' ) };
cellArray{ end , 2 } = '';
cellArray = cellArray';
charArray = [ cellArray{ : } ];
end 

return 


function stringWithNewLine = replaceChar10ByNewLine( stringWithChar10 )


stringWithNewLine = strrep( stringWithChar10, sprintf( '\n' ), '\n' );

return 


function value = getPropertyValue( propertyList, property )







[ m, n ] = size( propertyList );

value = '';

if ( m == 1 & rem( n, 2 ) == 0 ) | ( n == 2 )
pos = find( strcmpi( propertyList, property ) );
if ~isempty( pos )
if ( m == 1 )



value = propertyList{ pos( end  ) + 1 };
else 



value = propertyList{ pos( end  ), 2 };
end 
end 
end 

return 


function y = SetProperties( field, propertyList )



if ~isempty( propertyList )
[ m, n ] = size( propertyList );

if ( m == 1 & rem( n, 2 ) == 0 )



set( field, propertyList( 1:2:end  ), propertyList( 2:2:end  ) );
else 
if n == 2



set( field, propertyList( :, 1 )', propertyList( :, 2 )' );
end 
end 
end 

return 


function y = CreatePushbutton( parentWindow, visibility,  ...
enable, position, properties )


y = uicontrol( 'Parent', parentWindow,  ...
'Style', 'Pushbutton',  ...
'String', '',  ...
'Units', 'Characters',  ...
'Visible', visibility,  ...
'Enable', enable,  ...
'Position', position );

if nargin > 4
SetProperties( y, properties );
end 

return 


function y = CreateText( parentWindow,  ...
visibility, enable, position, properties )


backgroundcolor = get( parentWindow, 'color' );

y = uicontrol( 'Parent', parentWindow,  ...
'Style', 'Text',  ...
'String', '',  ...
'BackgroundColor', backgroundcolor,  ...
'HorizontalAlignment', 'Left',  ...
'Units', 'Characters',  ...
'Visible', visibility,  ...
'Enable', enable,  ...
'Position', position );

if nargin > 4
SetProperties( y, properties );
end 

return 


function y = CreateEdit( parentWindow,  ...
visibility, enable, position, properties )


y = uicontrol( 'Parent', parentWindow,  ...
'Style', 'Edit',  ...
'Backgroundcolor', 'White',  ...
'String', '',  ...
'HorizontalAlignment', 'Left',  ...
'Units', 'Characters',  ...
'Visible', visibility,  ...
'Enable', enable,  ...
'Position', position );

if nargin > 4
SetProperties( y, properties );
end 

return 


function y = CreateCheckbox( parentWindow,  ...
visibility, enable, position, properties )


backgroundcolor = get( parentWindow, 'color' );

y = uicontrol( 'Parent', parentWindow,  ...
'Style', 'CheckBox',  ...
'String', '',  ...
'Value', 1,  ...
'BackgroundColor', backgroundcolor,  ...
'Units', 'Characters',  ...
'Visible', visibility,  ...
'Enable', enable,  ...
'Position', position );

if nargin > 4
SetProperties( y, properties );
end 

return 


function y = CreateFrame( parentWindow, visibility, position, properties )


backgroundcolor = get( parentWindow, 'color' );

y = uicontrol( 'Parent', parentWindow,  ...
'Style', 'Frame',  ...
'String', '',  ...
'BackgroundColor', backgroundcolor,  ...
'Units', 'Characters',  ...
'Visible', visibility,  ...
'Position', position );

if nargin > 4
SetProperties( y, properties );
end 

return 


function y = CreatePopup( parentWindow,  ...
visibility, enable, position, properties )


y = uicontrol( 'Parent', parentWindow,  ...
'Style', 'Popup',  ...
'String', '',  ...
'Backgroundcolor', 'white',  ...
'Units', 'Characters',  ...
'Visible', visibility,  ...
'Enable', enable,  ...
'Position', position );

if nargin > 4
SetProperties( y, properties );
end 

return 


function y = CreateList( parentWindow,  ...
visibility, enable, position, properties )


y = uicontrol( 'Parent', parentWindow,  ...
'Style', 'ListBox',  ...
'Backgroundcolor', 'White',  ...
'String', '',  ...
'Units', 'Characters',  ...
'Visible', visibility,  ...
'Enable', enable,  ...
'Position', position );

if nargin > 4
SetProperties( y, properties );
end 

return 



function y = MultipleLineEditWidget( varargin )






parentWindow = varargin{ 1 };
top = varargin{ 2 };
sameTop = varargin{ 3 };
textInfo = varargin{ 4 };
editInfo = varargin{ 5 };
visibility = varargin{ 6 };
enable = varargin{ 7 };




z = dimension;
buttonWidth = z.buttonWidth;
buttonHeight = z.buttonHeight;
textHeight = z.textHeight;
leftAlignment = z.leftAlignment;

bottom = top - textHeight;




position = [ textInfo.left, bottom, textInfo.width, textHeight ];
y.text = CreateText( parentWindow,  ...
visibility, enable, position, textInfo.properties );

if sameTop
bottom = top;
end 

bottom = bottom - editInfo.height;




position = [ editInfo.left, bottom, editInfo.width, editInfo.height ];
y.edit = CreateEdit( parentWindow, visibility, enable,  ...
position, { 'Min', 1, 'Max', 5000 } );
SetProperties( y.edit, editInfo.properties );

string = getPropertyValue( editInfo.properties, 'String' );
string = getCellArrayFromCharArray( string );
set( y.edit, 'String', string );

return 


function y = PopupWidget( varargin )






parentWindow = varargin{ 1 };
top = varargin{ 2 };
textInfo = varargin{ 3 };
popupInfo = varargin{ 4 };
visibility = varargin{ 5 };
enable = varargin{ 6 };




z = dimension;
buttonWidth = z.buttonWidth;
buttonHeight = z.buttonHeight;
textHeight = z.textHeight;
leftAlignment = z.leftAlignment;

bottom = top - textHeight;




position = [ textInfo.left, bottom - ( textHeight - 1 ) / 2, textInfo.width, textHeight ];
y.text = CreateText( parentWindow,  ...
visibility, enable, position, textInfo.properties );

position = [ popupInfo.left, bottom, popupInfo.width, textHeight ];
y.popup = CreatePopup( parentWindow,  ...
visibility, enable, position, popupInfo.properties );

return 


function y = CheckboxWidget( varargin )





parentWindow = varargin{ 1 };
top = varargin{ 2 };
checkboxInfo = varargin{ 3 };
visibility = varargin{ 4 };
enable = varargin{ 5 };




z = dimension;
buttonWidth = z.buttonWidth;
buttonHeight = z.buttonHeight;
textHeight = z.textHeight;
leftAlignment = z.leftAlignment;

bottom = top - textHeight;
position = [ checkboxInfo.left, bottom, checkboxInfo.width, textHeight ];
y.checkbox = CreateCheckbox( parentWindow, visibility,  ...
enable, position, checkboxInfo.properties );

return 


function y = ListWidget( varargin )






parentWindow = varargin{ 1 };
top = varargin{ 2 };
sameTop = varargin{ 3 };
textInfo = varargin{ 4 };
listInfo = varargin{ 5 };
visibility = varargin{ 6 };
enable = varargin{ 7 };




z = dimension;
buttonWidth = z.buttonWidth;
buttonHeight = z.buttonHeight;
textHeight = z.textHeight;
leftAlignment = z.leftAlignment;

bottom = top - textHeight;




position = [ textInfo.left, bottom, textInfo.width, textHeight ];
y.text = CreateText( parentWindow,  ...
visibility, enable, position, textInfo.properties );

if sameTop
bottom = top;
end 

bottom = bottom - listInfo.height;
position = [ listInfo.left, bottom, listInfo.width, listInfo.height ];
y.list = CreateList( parentWindow,  ...
visibility, enable, position, listInfo.properties );

return 


function y = FrameWidget( varargin )





parentWindow = varargin{ 1 };
top = varargin{ 2 };
frameInfo = varargin{ 3 };
visibility = varargin{ 4 };

bottom = top - frameInfo.height;




position = [ frameInfo.left, bottom, frameInfo.width, frameInfo.height ];
y.frame = CreateFrame( parentWindow,  ...
visibility, position, frameInfo.properties );

return 



function outGeom = i_sluigeom

























fudgeFactors = i_CreateGeomStructForCharUnits;

outGeom.pushbutton = fudgeFactors( 1, : );
outGeom.radiobutton = fudgeFactors( 2, : );
outGeom.checkbox = fudgeFactors( 3, : );
outGeom.edit = fudgeFactors( 4, : );
outGeom.text = fudgeFactors( 5, : );
outGeom.slider = fudgeFactors( 6, : );
outGeom.frame = fudgeFactors( 7, : );
outGeom.listbox = fudgeFactors( 8, : );
outGeom.popupmenu = fudgeFactors( 9, : );
outGeom.listboxHscroll = fudgeFactors( 10, : );
outGeom.listboxVscroll = fudgeFactors( 11, : );










function geom = i_CreateGeomStructForCharUnits

if isunix
geom = [ 
0, 0, 2, 0.7
0, 0, 0, 0.55
0, 0, 3.6, 1
0, 0, 2, 0.7
0, 0, 0, 0.33
0, 0, 0, 0
0, 0, 0, 0
0, 0, 0, 0
0, 0, 5, 0.9
0, 0, 0, 0
0, 0, 0, 0
 ];
else 

assert( ispc )

geom = [ 
0, 0, 3, 0.6
0, 0, 0, 0.35
0, 0, 3.6, 0.1
0, 0, 3, 0.5
0, 0, 0.5, 0.3
0, 0, 0, 0
0, 0, 0, 0
0, 0, 0, 2
0, 0, 5, 0.55
0, 0, 0, 0
0, 0, 0, 0
 ];

end 


% Decoded using De-pcode utility v1.2 from file /tmp/tmp22gclI.p.
% Please follow local copyright laws when handling this file.

