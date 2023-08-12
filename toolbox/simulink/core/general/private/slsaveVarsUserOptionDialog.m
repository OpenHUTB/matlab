function varargout = slsaveVarsUserOptionDialog( varargin )




























gui_Singleton = 1;
gui_State = struct( 'gui_Name', mfilename,  ...
'gui_Singleton', gui_Singleton,  ...
'gui_OpeningFcn', @slsaveVarsUserOptionDialog_OpeningFcn,  ...
'gui_OutputFcn', @slsaveVarsUserOptionDialog_OutputFcn,  ...
'gui_LayoutFcn', @slsaveVarsUserOptionDialog_LayoutFcn,  ...
'gui_Callback', [  ] );
if nargin && ischar( varargin{ 1 } )
gui_State.gui_Callback = str2func( varargin{ 1 } );
end 

if nargout
[ varargout{ 1:nargout } ] = gui_mainfcn( gui_State, varargin{ : } );
else 
gui_mainfcn( gui_State, varargin{ : } );
end 




function slsaveVarsUserOptionDialog_OpeningFcn( hObject, eventdata, handles, varargin )%#ok







handles.output = hObject;


defaultOption = get( hObject, 'UserData' );
if ~isempty( defaultOption ) && ischar( defaultOption ) &&  ...
( strcmp( defaultOption, 'append' ) ||  ...
strcmp( defaultOption, 'update' ) )
set( handles.options, 'SelectedObject', handles.( defaultOption ) );
end 

set( handles.output, 'UserData', '' );


guidata( hObject, handles );


uiwait( handles.figure1 );



function varargout = slsaveVarsUserOptionDialog_OutputFcn( hObject, eventdata, handles )%#ok






varargout{ 1 } = get( handles.output, 'UserData' );

delete( handles.figure1 );



function okay_Callback( hObject, eventdata, handles )%#ok




h_selected_option = get( handles.options, 'SelectedObject' );
option_tag = strtrim( get( h_selected_option, 'Tag' ) );
if strcmp( option_tag, 'create' )
option = 'create';
elseif strcmp( option_tag, 'update' )
option = 'update';
elseif strcmp( option_tag, 'append' )
option = 'append';
else 
assert( false, 'unsupported option' );
end 

set( handles.output, 'UserData', option );

close( handles.figure1 );




function cancel_Callback( hObject, eventdata, handles )%#ok




set( handles.output, 'UserData', [  ] );
close( handles.figure1 );




function help_Callback( hObject, eventdata, handles )%#ok




doc( 'Simulink.saveVars' );



function figure1_CloseRequestFcn( hObject, eventdata, handles )%#ok





if isequal( get( hObject, 'waitstatus' ), 'waiting' )
uiresume( hObject );
else 
delete( hObject );
end 



function h1 = slsaveVarsUserOptionDialog_LayoutFcn( policy )


persistent hsingleton;
if strcmpi( policy, 'reuse' ) & ishandle( hsingleton )%#ok
h1 = hsingleton;
return ;
end 






appdata = [  ];
appdata.GUIDEOptions = struct(  ...
'active_h', [  ],  ...
'taginfo', struct(  ...
'figure', 2,  ...
'uipanel', 4,  ...
'pushbutton', 4,  ...
'radiobutton', 6 ),  ...
'override', 0,  ...
'release', 13,  ...
'resize', 'none',  ...
'accessibility', 'callback',  ...
'mfile', 1,  ...
'callbacks', 1,  ...
'singleton', 1,  ...
'syscolorfig', 1,  ...
'blocking', 0,  ...
'lastSavedFile', '',  ...
'lastFilename', '' );
appdata.lastValidTag = 'figure1';
appdata.GUIDELayoutEditor = [  ];
appdata.initTags = struct(  ...
'handle', [  ],  ...
'tag', 'figure1' );

h1 = figure(  ...
'Units', 'characters',  ...
'CloseRequestFcn', @( hObject, eventdata )slsaveVarsUserOptionDialog( 'figure1_CloseRequestFcn', hObject, eventdata, guidata( hObject ) ),  ...
'Color', [ 0.701960784313725, 0.701960784313725, 0.701960784313725 ],  ...
'Colormap', [ 0, 0, 0.5625;0, 0, 0.625;0, 0, 0.6875;0, 0, 0.75;0, 0, 0.8125;0, 0, 0.875;0, 0, 0.9375;0, 0, 1;0, 0.0625, 1;0, 0.125, 1;0, 0.1875, 1;0, 0.25, 1;0, 0.3125, 1;0, 0.375, 1;0, 0.4375, 1;0, 0.5, 1;0, 0.5625, 1;0, 0.625, 1;0, 0.6875, 1;0, 0.75, 1;0, 0.8125, 1;0, 0.875, 1;0, 0.9375, 1;0, 1, 1;0.0625, 1, 1;0.125, 1, 0.9375;0.1875, 1, 0.875;0.25, 1, 0.8125;0.3125, 1, 0.75;0.375, 1, 0.6875;0.4375, 1, 0.625;0.5, 1, 0.5625;0.5625, 1, 0.5;0.625, 1, 0.4375;0.6875, 1, 0.375;0.75, 1, 0.3125;0.8125, 1, 0.25;0.875, 1, 0.1875;0.9375, 1, 0.125;1, 1, 0.0625;1, 1, 0;1, 0.9375, 0;1, 0.875, 0;1, 0.8125, 0;1, 0.75, 0;1, 0.6875, 0;1, 0.625, 0;1, 0.5625, 0;1, 0.5, 0;1, 0.4375, 0;1, 0.375, 0;1, 0.3125, 0;1, 0.25, 0;1, 0.1875, 0;1, 0.125, 0;1, 0.0625, 0;1, 0, 0;0.9375, 0, 0;0.875, 0, 0;0.8125, 0, 0;0.75, 0, 0;0.6875, 0, 0;0.625, 0, 0;0.5625, 0, 0 ],  ...
'IntegerHandle', 'off',  ...
'InvertHardcopy', get( 0, 'defaultfigureInvertHardcopy' ),  ...
'MenuBar', 'none',  ...
'Name', DAStudio.message( 'Simulink:dialog:WorkspaceExportUserOptionDialogTitle' ),  ...
'WindowStyle', 'modal',  ...
'NumberTitle', 'off',  ...
'PaperPosition', get( 0, 'defaultfigurePaperPosition' ),  ...
'Position', [ 100, 50, 95, 15 ],  ...
'Resize', 'off',  ...
'HandleVisibility', 'callback',  ...
'UserData', [  ],  ...
'Tag', 'figure1',  ...
'Visible', 'on',  ...
'CreateFcn', { @local_CreateFcn, blanks( 0 ), appdata } );

appdata = [  ];
appdata.lastValidTag = 'okay';

h2 = uicontrol(  ...
'Parent', h1,  ...
'Units', 'characters',  ...
'Callback', @( hObject, eventdata )slsaveVarsUserOptionDialog( 'okay_Callback', hObject, eventdata, guidata( hObject ) ),  ...
'FontSize', 10,  ...
'Position', [ 25, 1.125, 12, 1.8 ],  ...
'String', getString( message( 'Simulink:dialog:DCDOK' ) ),  ...
'Tag', 'okay',  ...
'CreateFcn', { @local_CreateFcn, blanks( 0 ), appdata } );

appdata = [  ];
appdata.lastValidTag = 'cancel';

h3 = uicontrol(  ...
'Parent', h1,  ...
'Units', 'characters',  ...
'Callback', @( hObject, eventdata )slsaveVarsUserOptionDialog( 'cancel_Callback', hObject, eventdata, guidata( hObject ) ),  ...
'FontSize', 10,  ...
'Position', [ 41, 1.125, 12, 1.8 ],  ...
'String', getString( message( 'Simulink:dialog:SfunCancel' ) ),  ...
'Tag', 'cancel',  ...
'CreateFcn', { @local_CreateFcn, blanks( 0 ), appdata } );

appdata = [  ];
appdata.lastValidTag = 'help';

h4 = uicontrol(  ...
'Parent', h1,  ...
'Units', 'characters',  ...
'Callback', @( hObject, eventdata )slsaveVarsUserOptionDialog( 'help_Callback', hObject, eventdata, guidata( hObject ) ),  ...
'FontSize', 10,  ...
'Position', [ 57, 1.125, 12, 1.8 ],  ...
'String', getString( message( 'Simulink:dialog:DCDHelp' ) ),  ...
'Tag', 'help',  ...
'CreateFcn', { @local_CreateFcn, blanks( 0 ), appdata } );

appdata = [  ];
appdata.lastValidTag = 'uipanel3';

h5 = uibuttongroup(  ...
'Parent', h1,  ...
'Units', 'characters',  ...
'FontSize', 10,  ...
'Title', DAStudio.message( 'Simulink:dialog:WorkspaceExportUserOptions' ),  ...
'Tag', 'options',  ...
'Clipping', 'on',  ...
'Position', [ 3.14285714285714, 4.1875, 88.5, 10 ],  ...
'SelectedObject', [  ],  ...
'SelectionChangeFcn', [  ],  ...
'OldSelectedObject', [  ],  ...
'CreateFcn', { @local_CreateFcn, blanks( 0 ), appdata } );

appdata = [  ];
appdata.lastValidTag = 'create';

h6 = uicontrol(  ...
'Parent', h5,  ...
'Units', 'characters',  ...
'Callback', [  ],  ...
'FontSize', 10,  ...
'Position', [ 2, 6, 85, 1.25 ],  ...
'String', DAStudio.message( 'Simulink:dialog:WorkspaceExportUserOptionCreate', '' ),  ...
'Style', 'radiobutton',  ...
'Value', 1,  ...
'Tag', 'create',  ...
'CreateFcn', { @local_CreateFcn, blanks( 0 ), appdata } );

appdata = [  ];
appdata.lastValidTag = 'update';

h7 = uicontrol(  ...
'Parent', h5,  ...
'Units', 'characters',  ...
'Callback', [  ],  ...
'FontSize', 10,  ...
'Position', [ 2, 0.875, 85, 1.25 ],  ...
'String', DAStudio.message( 'Simulink:dialog:WorkspaceExportUserOptionUpdate', '' ),  ...
'Style', 'radiobutton',  ...
'Tag', 'update',  ...
'CreateFcn', { @local_CreateFcn, blanks( 0 ), appdata } );

appdata = [  ];
appdata.lastValidTag = 'append';

h8 = uicontrol(  ...
'Parent', h5,  ...
'Units', 'characters',  ...
'Callback', [  ],  ...
'FontSize', 10,  ...
'Position', [ 2, 3.5, 85, 1.25 ],  ...
'String', DAStudio.message( 'Simulink:dialog:WorkspaceExportUserOptionAppend', '' ),  ...
'Style', 'radiobutton',  ...
'Tag', 'append',  ...
'CreateFcn', { @local_CreateFcn, blanks( 0 ), appdata } );


hsingleton = h1;



function local_CreateFcn( hObject, eventdata, createfcn, appdata )

if ~isempty( appdata )
names = fieldnames( appdata );
for i = 1:length( names )
name = char( names( i ) );
setappdata( hObject, name, getfield( appdata, name ) );
end 
end 

if ~isempty( createfcn )
if isa( createfcn, 'function_handle' )
createfcn( hObject, eventdata );
else 
eval( createfcn );
end 
end 



function varargout = gui_mainfcn( gui_State, varargin )

gui_StateFields = { 'gui_Name'
'gui_Singleton'
'gui_OpeningFcn'
'gui_OutputFcn'
'gui_LayoutFcn'
'gui_Callback' };
gui_Mfile = '';
for i = 1:length( gui_StateFields )
if ~isfield( gui_State, gui_StateFields{ i } )
error( message( 'Simulink:dialog:FieldNotFound', gui_StateFields{ i }, gui_Mfile ) );
elseif isequal( gui_StateFields{ i }, 'gui_Name' )
gui_Mfile = [ gui_State.( gui_StateFields{ i } ), '.m' ];
end 
end 

numargin = length( varargin );

if numargin == 0



gui_Create = true;
elseif local_isInvokeActiveXCallback( gui_State, varargin{ : } )

vin{ 1 } = gui_State.gui_Name;
vin{ 2 } = [ get( varargin{ 1 }.Peer, 'Tag' ), '_', varargin{ end  } ];
vin{ 3 } = varargin{ 1 };
vin{ 4 } = varargin{ end  - 1 };
vin{ 5 } = guidata( varargin{ 1 }.Peer );
feval( vin{ : } );
return ;
elseif local_isInvokeHGCallback( gui_State, varargin{ : } )

gui_Create = false;
else 


gui_Create = true;
end 

if ~gui_Create




designEval = false;
if ( numargin > 1 && ishghandle( varargin{ 2 } ) )
fig = ancestor( varargin{ 2 }, 'figure' );

designEval = isappdata( 0, 'CreatingGUIDEFigure' ) || isprop( fig, 'GUIDEFigure' );
end 

if designEval
beforeChildren = findall( fig );
end 


varargin{ 1 } = gui_State.gui_Callback;
if nargout
[ varargout{ 1:nargout } ] = feval( varargin{ : } );
else 
feval( varargin{ : } );
end 




if designEval && ishandle( fig )
set( setdiff( findall( fig ), beforeChildren ), 'Serializable', 'off' );
end 
else 
if gui_State.gui_Singleton
gui_SingletonOpt = 'reuse';
else 
gui_SingletonOpt = 'new';
end 



gui_Visible = 'auto';
gui_VisibleInput = '';
for index = 1:2:length( varargin )
if length( varargin ) == index || ~ischar( varargin{ index } )
break ;
end 


len1 = min( length( 'visible' ), length( varargin{ index } ) );
len2 = min( length( 'off' ), length( varargin{ index + 1 } ) );
if ischar( varargin{ index + 1 } ) && strncmpi( varargin{ index }, 'visible', len1 ) && len2 > 1
if strncmpi( varargin{ index + 1 }, 'off', len2 )
gui_Visible = 'invisible';
gui_VisibleInput = 'off';
elseif strncmpi( varargin{ index + 1 }, 'on', len2 )
gui_Visible = 'visible';
gui_VisibleInput = 'on';
end 
end 
end 






gui_Exported = ~isempty( gui_State.gui_LayoutFcn );



setappdata( 0, genvarname( [ 'OpenGuiWhenRunning_', gui_State.gui_Name ] ), 1 );
if gui_Exported
gui_hFigure = feval( gui_State.gui_LayoutFcn, gui_SingletonOpt );



if isempty( gui_VisibleInput )
gui_VisibleInput = get( gui_hFigure, 'Visible' );
end 
set( gui_hFigure, 'Visible', 'off' )



movegui( gui_hFigure, 'onscreen' );
else 
gui_hFigure = local_openfig( gui_State.gui_Name, gui_SingletonOpt, gui_Visible );


if isappdata( gui_hFigure, 'InGUIInitialization' )
delete( gui_hFigure );
gui_hFigure = local_openfig( gui_State.gui_Name, gui_SingletonOpt, gui_Visible );
end 
end 
if isappdata( 0, genvarname( [ 'OpenGuiWhenRunning_', gui_State.gui_Name ] ) )
rmappdata( 0, genvarname( [ 'OpenGuiWhenRunning_', gui_State.gui_Name ] ) );
end 


setappdata( gui_hFigure, 'InGUIInitialization', 1 );


gui_Options = getappdata( gui_hFigure, 'GUIDEOptions' );

gui_Options.singleton = gui_State.gui_Singleton;

if ~isappdata( gui_hFigure, 'GUIOnScreen' )

if gui_Options.syscolorfig
set( gui_hFigure, 'Color', get( 0, 'DefaultUicontrolBackgroundColor' ) );
end 



data = guidata( gui_hFigure );
handles = guihandles( gui_hFigure );
if ~isempty( handles )
if isempty( data )
data = handles;
else 
names = fieldnames( handles );
for k = 1:length( names )
data.( char( names( k ) ) ) = handles.( char( names( k ) ) );
end 
end 
end 
guidata( gui_hFigure, data );
end 


for index = 1:2:length( varargin )
if length( varargin ) == index || ~ischar( varargin{ index } )
break ;
end 

len1 = min( length( 'visible' ), length( varargin{ index } ) );
if ~strncmpi( varargin{ index }, 'visible', len1 )
try set( gui_hFigure, varargin{ index }, varargin{ index + 1 } )
catch %#ok
break ;
end 
end 
end 



gui_HandleVisibility = get( gui_hFigure, 'HandleVisibility' );
if strcmp( gui_HandleVisibility, 'callback' )
set( gui_hFigure, 'HandleVisibility', 'on' );
end 

feval( gui_State.gui_OpeningFcn, gui_hFigure, [  ], guidata( gui_hFigure ), varargin{ : } );

if isscalar( gui_hFigure ) && ishandle( gui_hFigure )


guidemfile( 'restoreToolbarToolPredefinedCallback', gui_hFigure );


set( gui_hFigure, 'HandleVisibility', gui_HandleVisibility );



if ~gui_Exported
gui_hFigure = local_openfig( gui_State.gui_Name, 'reuse', gui_Visible );
elseif ~isempty( gui_VisibleInput )
set( gui_hFigure, 'Visible', gui_VisibleInput );
end 
if strcmpi( get( gui_hFigure, 'Visible' ), 'on' )
figure( gui_hFigure );

if gui_Options.singleton
setappdata( gui_hFigure, 'GUIOnScreen', 1 );
end 
end 


if isappdata( gui_hFigure, 'InGUIInitialization' )
rmappdata( gui_hFigure, 'InGUIInitialization' );
end 



gui_HandleVisibility = get( gui_hFigure, 'HandleVisibility' );
if strcmp( gui_HandleVisibility, 'callback' )
set( gui_hFigure, 'HandleVisibility', 'on' );
end 
gui_Handles = guidata( gui_hFigure );
else 
gui_Handles = [  ];
end 

if nargout
[ varargout{ 1:nargout } ] = feval( gui_State.gui_OutputFcn, gui_hFigure, [  ], gui_Handles );
else 
feval( gui_State.gui_OutputFcn, gui_hFigure, [  ], gui_Handles );
end 

if isscalar( gui_hFigure ) && ishandle( gui_hFigure )
set( gui_hFigure, 'HandleVisibility', gui_HandleVisibility );
end 
end 

function gui_hFigure = local_openfig( name, singleton, visible )



if nargin( 'openfig' ) == 2



gui_OldDefaultVisible = get( 0, 'defaultFigureVisible' );
set( 0, 'defaultFigureVisible', 'off' );
gui_hFigure = openfig( name, singleton );
set( 0, 'defaultFigureVisible', gui_OldDefaultVisible );
else 
gui_hFigure = openfig( name, singleton, visible );
end 

function result = local_isInvokeActiveXCallback( gui_State, varargin )%#ok

try 
result = ispc && iscom( varargin{ 1 } ) ...
 && isequal( varargin{ 1 }, gcbo );
catch %#ok
result = false;
end 

function result = local_isInvokeHGCallback( gui_State, varargin )

try 
fhandle = functions( gui_State.gui_Callback );
result = ~isempty( findstr( gui_State.gui_Name, fhandle.file ) ) ||  ...
( ischar( varargin{ 1 } ) ...
 && isequal( ishandle( varargin{ 2 } ), 1 ) ...
 && ( ~isempty( strfind( varargin{ 1 }, [ get( varargin{ 2 }, 'Tag' ), '_' ] ) ) ||  ...
~isempty( strfind( varargin{ 1 }, '_CreateFcn' ) ) ) );
catch %#ok
result = false;
end 



% Decoded using De-pcode utility v1.2 from file /tmp/tmpfcG91a.p.
% Please follow local copyright laws when handling this file.

