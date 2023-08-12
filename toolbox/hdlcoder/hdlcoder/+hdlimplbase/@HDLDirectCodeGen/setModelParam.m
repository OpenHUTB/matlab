function [  ] = setModelParam( this, srcModelName, targetModelName, exceptions )






maskProperty = [ ' MaskType', 'MaskDescription', ' MaskHelp', ' MaskPromptString', ' MaskStyleString',  ...
' MaskTunableValueString', ' MaskEnableString', ' MaskVisibilityString', ' MaskToolTipString',  ...
' MaskVarAliasString', ' MaskVariables', ' MaskInitialization', ' MaskDisplay', ' MaskCallbackString',  ...
' MaskSelfModifiable', ' MaskIconFrame', ' MaskIconOpaque', ' MaskIconRotate', ' MaskIconUnits',  ...
' MaskValueString', ' MaskRunInitForIconRedraw', ' Mask', ' MaskEditorHandle', ' MaskCallbacks',  ...
' MaskEnables', ' MaskNames', ' MaskPropertyNameString', ' MaskPrompts', ' MaskStyles',  ...
' MaskTunableValues', ' MaskValues', ' MaskToolTipsDisplay', ' MaskVisibilities',  ...
' MaskVarAliases', ' MaskWSVariables', ' MaskTabNameString', ' MaskTabNames' ];
exceptions = [ maskProperty, exceptions, ' Name', ' CurrentBlock', ' HDLConfigFile', ' LinkStatus', ' Parameters' ];
srcObject = get_param( srcModelName, 'ObjectParameters' );
srcField = fieldnames( srcObject );
targetObject = get_param( targetModelName, 'ObjectParameters' );
targetField = fieldnames( targetObject );
field = intersect( srcField, targetField );
for i = 1:numel( field )
prop = field{ i };
attr = cell2mat( ( srcObject.( prop ).Attributes ) );
if isempty( strfind( exceptions, prop ) ) && isempty( strfind( attr, 'write-only' ) ) && isempty( strfind( attr, 'read-only' ) )
val = get_param( srcModelName, prop );
set_param( targetModelName, prop, val );
end 
end 

% Decoded using De-pcode utility v1.2 from file /tmp/tmp2cZQRv.p.
% Please follow local copyright laws when handling this file.

