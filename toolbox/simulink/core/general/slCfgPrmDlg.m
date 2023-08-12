function ret = slCfgPrmDlg( varargin )
























































[ varargin{ : } ] = convertStringsToChars( varargin{ : } );

ret = [  ];
errmsg = '';%#ok

if nargin < 2
DAStudio.error( 'Simulink:dialog:MissingInpArgs' );
end 

cs = configset.internal.util.getConfigSet( varargin{ 1 } );
cs_cache = [  ];

hDlg = cs.getDialogHandle;




if ~isempty( hDlg ) && isa( hDlg, 'DAStudio.Dialog' )
cs_cache = cs.getConfigSetCache;
end 


action = varargin{ 2 };
if isempty( action ) || ~ischar( action )
DAStudio.error( 'Simulink:dialog:SecondInpArgValidStr' );
end 

switch action
case 'Open'

cs.openDialog(  );

if nargin == 3
pageName = varargin{ 3 };
if ~iscell( pageName )
pageNames = { pageName };
else 
pageNames = pageName;
end 
configset.showParameterGroup( cs, pageNames );
end 

case 'OpenLibSim'
configset.internal.util.openLibraryDialog( cs, "Sim" );

case 'OpenLibRTW'
configset.internal.util.openLibraryDialog( cs, "RTW" );

case 'Close'
cs.closeDialog(  );

case 'TurnToPage'
if nargin < 3
DAStudio.error( 'Simulink:dialog:ActionReqrThirdInpArgSpecPage', 'TurnToPage' );
end 


pageName = varargin{ 3 };


dlg = cs.getDialogHandle;
if isempty( dlg )
DAStudio.error( 'Simulink:dialog:CSTurnToPageError' );
else 
configset.showParameterGroup( cs, pageName );
end 
return ;

case 'GetCurrentPage'
ret = slprivate( 'cfgDlgStripHighlightPageName', cs.CurrentDlgPage );

case { 'Param2UI', 'Highlight' }
if nargin < 3
DAStudio.error( 'Simulink:dialog:ActionReqrThirdInpArgInterPrm', action );
end 
if nargin > 4
DAStudio.error( 'Simulink:dialog:CSActionExtraArg', action );
end 


paramNames = varargin{ 3 };

if strcmp( action, 'Highlight' )
configset.highlightParameter( cs, paramNames );
else 
if iscell( paramNames )
for i = 1:length( paramNames )
paramName = paramNames{ i };
if isempty( paramName ) || ~ischar( paramName )
DAStudio.error( 'Simulink:dialog:PrmMustBeStr' );
end 
end 
else 
if isempty( paramNames ) || ~ischar( paramNames )
DAStudio.error( 'Simulink:dialog:PrmMustBeStr' );
end 
end 

if isa( cs, 'Simulink.ConfigSetRef' )
cs = cs.getRefConfigSet;
cs_cache = cs.getConfigSetCache;
end 
if isempty( cs_cache )
cs_cache = cs;
end 

hModel = get_param( cs.getModel, 'Object' );

if ~isempty( hModel ) && hModel.isLibrary
DAStudio.error( 'Simulink:dialog:NotSupportforLib' );
end 

layoutModel = configset.internal.getConfigSetCategoryLayout;





adp = configset.internal.data.ConfigSetAdapter( cs_cache );
uiItem = layoutModel.param2UI( adp, paramNames );

if ~iscell( uiItem ) && isempty( uiItem )
DAStudio.error( 'Simulink:dialog:NoSuchParameter', paramNames );
end 

ret = uiItem;
end 

case 'UI2Param'
if nargin < 3
DAStudio.error( 'Simulink:dialog:ActionReqrThirdInpArgSpecUI', 'UI2Param' );
end 


arg3 = varargin{ 3 };
if iscell( arg3 )
for i = 1:length( arg3 )
uiName = arg3{ i };
if isempty( uiName ) || ~ischar( uiName )
DAStudio.error( 'Simulink:dialog:IncorrectUIDesc' );
end 
end 
else 
if isempty( arg3 ) || ~ischar( arg3 ) && ~isa( arg3, 'struct' )
DAStudio.error( 'Simulink:dialog:IncorrectUIDesc' );
end 
end 

if isa( cs, 'Simulink.ConfigSetRef' )
cs = cs.getRefConfigSet;
cs_cache = cs.getConfigSetCache;
end 
if ~isempty( cs_cache )
ret = slprivate( 'slCSPropGUIQuickMapping', cs_cache, arg3, action );
else 
ret = slprivate( 'slCSPropGUIQuickMapping', cs, arg3, action );
end 
ret = ret';

case 'ClearHighlights'
if nargin > 2
DAStudio.error( 'Simulink:dialog:CSActionExtraArg', action );
end 

configset.clearParameterHighlights( cs );

case 'getDialogHandle'
ret = cs.getDialogHandle;

otherwise 
DAStudio.error( 'Simulink:dialog:UnsupportedAct' );
end 

% Decoded using De-pcode utility v1.2 from file /tmp/tmp3dwZyj.p.
% Please follow local copyright laws when handling this file.

