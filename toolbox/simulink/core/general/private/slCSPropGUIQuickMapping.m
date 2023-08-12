function result = slCSPropGUIQuickMapping( hObj, names, varargin )


















if ~isa( hObj, 'Simulink.BaseConfig' )
return ;
end 

if nargin < 3 || strcmp( varargin{ 1 }, 'Param2UI' )
param2ui = true;
else 
param2ui = false;
if ~strcmp( varargin{ 1 }, 'UI2Param' )
return ;
end 
end 

global slCSPropGUIQM_found;
if iscell( names )
slCSPropGUIQM_found = zeros( 1, length( names ) );
else 
slCSPropGUIQM_found = 0;
end 



if ~param2ui
result = loc_layoutModelUI2Param( names, hObj );
clear global slCSPropGUIQM_found;
return ;
end 

if nargin < 5
handle = configset.internal.util.getSchema( hObj, 'Category View' );
if length( handle.Items ) < 2
result = 'isLib';
clear global slCSPropGUIQM_found;
return ;
end 

items = handle.Items{ 1 }.Items;
tree = loc_stripTreeHighlighting( handle.Items{ 2 }.TreeItems );
else 

handle = varargin{ 3 }.Items{ 1 }.Items{ 2 };

items = handle{ 1 }.Items;
tree = loc_stripTreeHighlighting( handle{ 2 }.TreeItems );
end 

global slCSPropGUIQM_enabled;
if nargin < 4
slCSPropGUIQM_enabled = 0;
else 
slCSPropGUIQM_enabled = varargin{ 2 };
end 

if param2ui
result = loc_param2UI( hObj, names, items, tree );
else 
result = loc_ui2Param( names, items, tree );
end 

clear global slCSPropGUIQM_enabled;
clear global slCSPropGUIQM_found;
end 


function result = loc_param2UI( hObj, names, items, tree )

global slCSPropGUIQM_paramNames;
global slCSPropGUIQM_outputUIs;

global slCSPropGUIQM_enabled;

slCSPropGUIQM_paramNames = containers.Map;
if iscell( names )
len = length( names );
slCSPropGUIQM_outputUIs = cell( 1, len );
else 
len = 1;
slCSPropGUIQM_outputUIs = [  ];
end 

if iscell( names )
for i = 1:len

if slCSPropGUIQM_paramNames.isKey( names{ i } )
n = slCSPropGUIQM_paramNames( names{ i } );
slCSPropGUIQM_paramNames( names{ i } ) = [ n, i ];
else 
slCSPropGUIQM_paramNames( names{ i } ) = i;
end 
end 
else 
slCSPropGUIQM_paramNames( names ) = 0;
end 

UIname = [  ];

for i = 1:length( items )
path = loc_getPath( '', 1, i, tree );
[ uiname, resultCount ] = iterate_param2ui( items{ i }, path, len );
UIname = [ UIname, uiname ];
if resultCount == len
break ;
end 
end 

exceptionList = loc_Visibility_ExceptionList(  );

for i = 1:length( exceptionList )
if slCSPropGUIQM_paramNames.isKey( exceptionList{ i } )
idx = slCSPropGUIQM_paramNames( exceptionList{ i } );
for j = 1:length( idx )
if idx( j ) == 0
if ~isempty( slCSPropGUIQM_outputUIs )
slCSPropGUIQM_outputUIs.Visible = 1;
end 
else 
if ~isempty( slCSPropGUIQM_outputUIs{ idx( j ) } )
slCSPropGUIQM_outputUIs{ idx( j ) }.Visible = 1;
end 
end 
end 
end 
end 

loc_tlmg_Visibility( hObj );



if resultCount < len
props = hObj.getProp;


hdl = hObj.getComponent( 'HDL Coder' );
if ~isempty( hdl ) && ~isempty( hdl.getCLI )
mcs = configset.internal.getConfigSetStaticData;
hdlParams = mcs.getComponent( 'hdlcoderui.hdlcc' ).ParamList;
props = [ props;cellfun( @( p )p.Name, hdlParams', 'UniformOutput', false ) ];
end 
nonUI = setdiff( props, UIname );

nonUIParam.Param = '';
nonUIParam.Prompt = '';
nonUIParam.Path = '';
nonUIParam.Type = 'NonUI';
nonUIParam.Tag = '';
nonUIParam.Visible = 0;
if slCSPropGUIQM_enabled
nonUIParam.Enabled = 0;
end 

if ischar( names )
if isempty( slCSPropGUIQM_outputUIs ) && ismember( names, nonUI )
slCSPropGUIQM_outputUIs = nonUIParam;
slCSPropGUIQM_outputUIs.Param = names;
end 
else 
for i = 1:len
if isempty( slCSPropGUIQM_outputUIs{ i } ) && ismember( names{ i }, nonUI )
slCSPropGUIQM_outputUIs{ i } = nonUIParam;
slCSPropGUIQM_outputUIs{ i }.Param = names{ i };
end 
end 
end 
end 

result = slCSPropGUIQM_outputUIs;

clear global slCSPropGUIQM_paramNames;
clear global slCSPropGUIQM_outputUIs;
end 


function result = loc_ui2Param( names, items, tree )
global slCSPropGUIQM_found;

if ischar( names )
result = '';
len = 1;
else 
len = length( names );
result = cell( 1, len );
end 

global slCSPropGUIQM_hshTbl;
global slCSPropGUIQM_paramIndex;

slCSPropGUIQM_hshTbl = containers.Map;
slCSPropGUIQM_paramIndex = 1;

UI = [  ];
UIname = [  ];

for i = 1:length( items )
path = loc_getPath( '', 1, i, tree );
[ ui, uiname ] = iterate_ui2param( items{ i }, path );
UI = [ UI, ui ];%#ok
UIname = [ UIname, uiname ];%#ok
end 

if iscell( names )
for i = 1:len
if ~slCSPropGUIQM_found( i )
result{ i } = loc_getUI_UI2Param( UI, names{ i } );
end 
end 
else 
result = loc_getUI_UI2Param( UI, names );
end 

clear global slCSPropGUIQM_paramIndex;
clear global slCSPropGUIQM_hshTbl;

end 


function result = loc_layoutModelUI2Param( names, cs )


global slCSPropGUIQM_found;

if iscell( names )
len = length( names );
result = cell( 1, len );
if isa( names{ 1 }, 'struct' )
for i = 1:len
names{ i } = names{ i }.Prompt;
end 
end 
else 
result = {  };
if isa( names, 'struct' )
names = names.Prompt;
end 
end 
layout = configset.internal.getConfigSetCategoryLayout;
mcs = layout.MetaCS;


adp = configset.internal.data.ConfigSetAdapter( cs );
if isempty( adp.tlcInfo )
params = mcs.ParamList;
else 
params = [ adp.tlcInfo.values, mcs.ParamList ];
end 
for i = 1:length( params )
p = params{ i };
if ischar( names )
if strcmp( p.getPrompt( cs ), names )


owner = adp.getParamOwner( p.Name );
if ~isempty( owner ) && layout.isUIParam( p, cs )

result{ end  + 1 } = p.Name;%#ok<AGROW>
end 
end 
elseif iscell( names )
for j = 1:len
name = names{ j };
if strcmp( p.getPrompt( cs ), name )


owner = adp.getParamOwner( p.Name );
if ~isempty( owner ) && layout.isUIParam( p, cs )
result{ j }{ end  + 1 } = p.Name;
slCSPropGUIQM_found( j ) = 1;
end 
end 
end 
end 
end 
end 


function [ nameOnly, resultCount ] = iterate_param2ui( element, path, paramCount )
resultCount = 0;

nameOnly = [  ];
if isfield( element, 'Items' )
items = element.Items;
for i = 1:length( items )
[ names, branch_found ] = iterate_param2ui( items{ i }, path, paramCount );
resultCount = resultCount + branch_found;
if resultCount == paramCount
return ;
end 
if ~isempty( names )
nameOnly = [ nameOnly, names ];%#ok
end 
end 
elseif isfield( element, 'Tabs' )
tabs = element.Tabs;
for i = 1:length( tabs )
[ names, branch_found ] = iterate_param2ui( tabs{ i }, path, paramCount );
resultCount = resultCount + branch_found;
if resultCount == paramCount
return ;
end 
if ~isempty( names )
nameOnly = [ nameOnly, names ];%#ok
end 
end 
else 
if isfield( element, 'ObjectProperty' )
op = element.ObjectProperty;
resultCount = loc_addWidgetToOutput( element, op, path, false );
nameOnly = { op };



return ;
elseif isfield( element, 'UserData' ) && isfield( element.UserData, 'ObjectProperty' )
udop = element.UserData.ObjectProperty;
if isfield( element.UserData, 'RepeatedName' )
return ;
end 
if ischar( udop )
resultCount = loc_addWidgetToOutput( element, udop, path, true );
nameOnly = { udop };
return ;
elseif iscell( udop )
j = 0;
for i = 1:length( udop )
if ischar( udop{ i } )
j = j + 1;
resultCount = loc_addWidgetToOutput( element, udop{ i }, path, false );
names{ j } = udop{ i };%#ok
end 
end 
nameOnly = names;
return ;
end 
end 
end 
end 


function found = loc_addWidgetToOutput( element, name, path, isUserData )
global slCSPropGUIQM_outputUIs;
global slCSPropGUIQM_paramNames;

found = 0;
if slCSPropGUIQM_paramNames.isKey( name )
idx = slCSPropGUIQM_paramNames( name );
if idx == 0
slCSPropGUIQM_outputUIs = loc_getWidget( element, name, path, isUserData );
found = 1;
else 
for j = 1:length( idx )
if isempty( slCSPropGUIQM_outputUIs{ idx( j ) } )
slCSPropGUIQM_outputUIs{ idx( j ) } = loc_getWidget( element, name, path, isUserData );
found = found + 1;
end 
end 
end 
end 
end 



function [ result, nameOnly ] = iterate_ui2param( element, path )
global slCSPropGUIQM_paramIndex;
global slCSPropGUIQM_hshTbl;

result = [  ];
nameOnly = [  ];
if isfield( element, 'Items' )
items = element.Items;
for i = 1:length( items )
[ r, only ] = iterate_ui2param( items{ i }, path );
if ~isempty( r )
result = [ result, r ];%#ok
nameOnly = [ nameOnly, only ];%#ok
end 
end 
elseif isfield( element, 'Tabs' )
tabs = element.Tabs;
for i = 1:length( tabs )
[ r, only ] = iterate_ui2param( tabs{ i }, path );
if ~isempty( r )
result = [ result, r ];%#ok
nameOnly = [ nameOnly, only ];%#ok
end 
end 
else 
if isfield( element, 'ObjectProperty' )
r = loc_getWidget( element, element.ObjectProperty, path, false );
result = { r };
nameOnly = { element.ObjectProperty };
if ~slCSPropGUIQM_hshTbl.isKey( r.Prompt )
slCSPropGUIQM_hshTbl( r.Prompt ) = slCSPropGUIQM_paramIndex;
else 
slCSPropGUIQM_hshTbl = loc_hahTblPut( slCSPropGUIQM_hshTbl, r.Prompt, slCSPropGUIQM_hshTbl( r.Prompt ), slCSPropGUIQM_paramIndex );
end 
slCSPropGUIQM_paramIndex = slCSPropGUIQM_paramIndex + 1;
return ;
elseif isfield( element, 'UserData' ) && isfield( element.UserData, 'ObjectProperty' )
udop = element.UserData.ObjectProperty;
if isfield( element.UserData, 'RepeatedName' )
return ;
end 
if ischar( udop )
r = loc_getWidget( element, udop, path, true );
result = { r };
nameOnly = { udop };
if ~slCSPropGUIQM_hshTbl.isKey( r.Prompt )
slCSPropGUIQM_hshTbl( r.Prompt ) = slCSPropGUIQM_paramIndex;
else 
slCSPropGUIQM_hshTbl = loc_hahTblPut( slCSPropGUIQM_hshTbl, r.Prompt, slCSPropGUIQM_hshTbl( r.Prompt ), slCSPropGUIQM_paramIndex );
end 
slCSPropGUIQM_paramIndex = slCSPropGUIQM_paramIndex + 1;
return ;
elseif iscell( udop )
j = 0;
for i = 1:length( udop )
if ischar( udop{ i } )
j = j + 1;
r{ j } = loc_getWidget( element, udop{ i }, path, false );%#ok
only{ j } = udop{ i };%#ok
if ~slCSPropGUIQM_hshTbl.isKey( r{ j }.Prompt )
slCSPropGUIQM_hshTbl( r{ j }.Prompt ) = slCSPropGUIQM_paramIndex;
else 
slCSPropGUIQM_hshTbl = loc_hahTblPut( slCSPropGUIQM_hshTbl, r{ j }.Prompt, slCSPropGUIQM_hshTbl( r{ j }.Prompt ), slCSPropGUIQM_paramIndex );
end 
slCSPropGUIQM_paramIndex = slCSPropGUIQM_paramIndex + 1;
end 
end 
result = r;
nameOnly = only;
return ;
end 
end 
end 
end 


function [ path, curridx ] = loc_getPath( path, curridx, targetidx, tree )
for i = 1:length( tree )











if ischar( tree{ i } )
if ( curridx == targetidx )
path = tree{ i };
return ;
else 
if ( i < length( tree ) ) && iscell( tree{ i + 1 } )
[ path, curridx ] = loc_getPath( path, curridx + 1, targetidx, tree{ i + 1 } );
if ( curridx == targetidx )
if ~isempty( path )
path = [ tree{ i }, '/', path ];%#ok
return ;
end 
end 
else 
curridx = curridx + 1;
end 
end 
end 
end 
end 


function ui = loc_getWidget( element, name, path, userdata )
global slCSPropGUIQM_enabled;

ui.Param = name;
ui.Prompt = loc_getWidgetName( element );
ui.Path = path;
ui.Type = element.Type;

if userdata && isfield( element.UserData, 'Visible' )
ui.Visible = element.UserData.Visible;
elseif isfield( element, 'Visible' )
ui.Visible = element.Visible;
else 
ui.Visible = 1;
end 

if slCSPropGUIQM_enabled
if isfield( element, 'Enabled' )
ui.Enabled = element.Enabled;
else 
ui.Enabled = 1;
end 

if strcmpi( ui.Type, 'combobox' )
if isfield( element, 'Entries' )
ui.Entries = element.Entries;
end 
end 
end 

if isfield( element, 'Tag' )
ui.Tag = element.Tag;
else 
ui.Tag = '';
end 
end 

function name = loc_getWidgetName( widget )
if isfield( widget, 'Name' ) && ~isempty( widget.Name )
name = widget.Name;
elseif isfield( widget, 'UserData' )
if isfield( widget.UserData, 'Name' )
name = widget.UserData.Name;
else 
name = widget.UserData.ObjectProperty;
end 
else 
name = '';
end 
end 


function uis = loc_getUI_UI2Param( UI, names )
uis = [  ];

if isempty( names )
return ;
end 

prompt = names;
if isa( names, 'struct' )
prompt = names.Prompt;
end 

if ~isempty( prompt )
uis = loc_getUI_UI2Param_helper( UI, prompt );
end 
end 

function uis = loc_getUI_UI2Param_helper( UI, names )
global slCSPropGUIQM_hshTbl;

uis = [  ];
if slCSPropGUIQM_hshTbl.isKey( names )
idx = slCSPropGUIQM_hshTbl( names );
len = length( idx );
uis = cell( 1, len );
if ~iscell( idx )
uis{ 1 } = UI{ idx }.Param;
else 
for j = 1:len
uis{ j } = UI{ idx{ j } }.Param;
end 
end 
end 
end 

function slCSPropGUIQM_hshTbl = loc_hahTblPut( slCSPropGUIQM_hshTbl, prompt, existingIndex, newIndex )
len = length( existingIndex );
idx = cell( len + 1, 1 );

if len == 1
idx{ 1 } = existingIndex;
idx{ 2 } = newIndex;
else 
for k = 1:len
idx{ k } = existingIndex{ k };
end 
idx{ len + 1 } = newIndex;
end 

slCSPropGUIQM_hshTbl( prompt ) = idx;
end 

function tree_copy = loc_stripTreeHighlighting( tree )
tree_copy = cell( size( tree ) );

for i = 1:length( tree )
if ischar( tree{ i } )
tree_copy{ i } = cfgDlgStripHighlightPageName( tree{ i } );
if ( i < length( tree ) ) && iscell( tree{ i + 1 } )
tree_copy{ i + 1 } = loc_stripTreeHighlighting( tree{ i + 1 } );
end 
end 
end 
end 

function list = loc_Visibility_ExceptionList(  )
list = { 'SimCustomHeaderCode',  ...
'SimCustomInitializer',  ...
'SimCustomTerminator',  ...
'SimUserSources',  ...
'SimUserLibraries',  ...
'CustomHeaderCode',  ...
'CustomInitializer',  ...
'CustomTerminator',  ...
'CustomSource',  ...
'CustomLibrary' };
end 







function loc_tlmg_Visibility( cs )
global slCSPropGUIQM_outputUIs;

dataModel = configset.internal.getConfigSetAdapter( cs );
if iscell( slCSPropGUIQM_outputUIs )
for i = 1:length( slCSPropGUIQM_outputUIs )
if isempty( slCSPropGUIQM_outputUIs{ i } )
continue ;
end 
name = slCSPropGUIQM_outputUIs{ i }.Param;
if strncmp( name, 'tlmg', 4 ) &&  ...
slCSPropGUIQM_outputUIs{ i }.Visible &&  ...
dataModel.getParamStatus( name ) == configset.internal.data.ParamStatus.InAccessible
slCSPropGUIQM_outputUIs{ i }.Visible = 0;
end 
end 
elseif ~isempty( slCSPropGUIQM_outputUIs )
name = slCSPropGUIQM_outputUIs.Param;
if strncmp( name, 'tlmg', 4 ) &&  ...
slCSPropGUIQM_outputUIs.Visible &&  ...
dataModel.getParamStatus( name ) == configset.internal.data.ParamStatus.InAccessible
slCSPropGUIQM_outputUIs.Visible = 0;
end 
end 
end 




% Decoded using De-pcode utility v1.2 from file /tmp/tmpXQbxEl.p.
% Please follow local copyright laws when handling this file.

