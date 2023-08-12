function varargout = slDialogUtil( source, action, varargin )










switch action
case 'sync'
activeDlg = varargin{ 1 };
widgetType = varargin{ 2 };
paramName = varargin{ 3 };
syncDialogs( source, activeDlg, widgetType, paramName );

case 'getParamIndex'
paramName = varargin{ 1 };
varargout{ 1 } = getParamIndex( source, paramName );

case 'refactor'

otherwise 
warning( message( 'Simulink:dialog:unknownAction' ) );
end 


function index = getParamIndex( source, paramName )
index = 0;
paramsMap = [  ];
if isprop( source, 'paramsMap' ) && ~isempty( source.paramsMap )
paramsMap = source.paramsMap;
else 

if strcmp( source.getBlock.Mask, 'on' )
paramsMap = source.getBlock.MaskNames;
end 


if isempty( paramsMap )
paramsMap = fieldnames( source.state );
end 
end 
for i = 1:length( paramsMap )
if strcmp( paramsMap{ i }, paramName )
break ;
end 
index = index + 1;
end 


function syncDialogs( source, activeDlg, widgetType, paramName )
value = activeDlg.getWidgetValue( paramName );
index = slDialogUtil( source, 'getParamIndex', paramName );
switch widgetType
case 'edit'
source.handleEditEvent( value, index, activeDlg );
case 'checkbox'
source.handleCheckEvent( value, index, activeDlg );
case 'combobox'
source.handleComboSelectionEvent( value, index, activeDlg );
case 'radiobutton'
source.handleRadioButtonSelectionEvent( value, index, activeDlg );
otherwise 
warning( message( 'Simulink:dialog:unknownWidgetType' ) );
end 

% Decoded using De-pcode utility v1.2 from file /tmp/tmpwCAdFI.p.
% Please follow local copyright laws when handling this file.

