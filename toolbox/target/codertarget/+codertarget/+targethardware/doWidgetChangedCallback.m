function doWidgetChangedCallback( hObj, hDlg, tag, ~ )




if isa( hDlg, 'ConfigSet.DDGWrapper' )

loc_webWidgetChangedCallback( hObj, hDlg, tag );
else 

loc_ddgWidgetChangedCallback( hObj, hDlg, tag );
end 



function loc_ddgWidgetChangedCallback( hObj, hDlg, tag )
cs = hObj.getConfigSet(  );
tagprefix = 'Tag_ConfigSet_CoderTarget_';
ud = hDlg.getUserData( tag );
paramName = ud.Storage;
if isempty( paramName )
paramName = strrep( tag, tagprefix, '' );
end 
curVal = codertarget.data.getParameterValue( cs, paramName );
newVal = hDlg.getWidgetValue( tag );
if isnumeric( newVal ) && ~isnumeric( curVal )
newVal = hDlg.getComboBoxText( tag );
elseif ischar( newVal ) && isnumeric( curVal )
newVal = str2num( newVal );%#ok<ST2NM>
end 
if loc_checkRangeAndValue( ud, newVal )
codertarget.data.setParameterValue( cs, paramName, newVal );
else 
hDlg.setWidgetValue( tag, curVal );
end 



function loc_webWidgetChangedCallback( hObj, hDlg, tag )
cs = hObj.getConfigSet(  );
tagprefix = 'Tag_ConfigSet_CoderTarget_';
ud = hDlg.userData;
fieldName = ud.Storage;
if isempty( fieldName )
fieldName = strrep( tag, tagprefix, '' );
end 

curVal = codertarget.data.getParameterValue( cs, fieldName );
newVal = hDlg.value;

if isnumeric( newVal ) && ~isnumeric( curVal )
newVal = ud.Entries{ newVal + 1 };
elseif ischar( newVal ) && isnumeric( curVal )
newVal = str2num( newVal );%#ok<ST2NM>
end 

if loc_checkRangeAndValue( ud, newVal )
codertarget.data.setParameterValue( cs, fieldName, newVal );
end 



function out = loc_checkRangeAndValue( ud, newVal )
out = true;
if ( ~isempty( ud.ValueType ) && ~strcmpi( ud.ValueType, 'callback' ) ) || ~isempty( ud.ValueRange )
validRange = eval( ud.ValueRange );
if ~isnumeric( newVal )
newVal = eval( newVal );
end 
func = str2func( ud.ValueType );
val = func( newVal );
if isempty( val ) || ~isscalar( val ) || ~isreal( val ) ||  ...
val < func( validRange( 1 ) ) || val > func( validRange( 2 ) ) || ~isequal( newVal, val )
s1 = num2str( validRange( 1 ) );
s2 = num2str( validRange( 2 ) );
str = sprintf( 'Invalid value entered. The value must be between %s and %s.', s1, s2 );
errordlg( str, 'Coder Target Error Dialog', 'modal' );
out = false;
end 
end 

% Decoded using De-pcode utility v1.2 from file /tmp/tmpB3VpYa.p.
% Please follow local copyright laws when handling this file.

