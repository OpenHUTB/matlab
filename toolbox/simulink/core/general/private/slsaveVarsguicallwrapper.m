function slsaveVarsguicallwrapper( varargin )




syntaxCorrect = true;
if length( varargin ) == 3
if ~ischar( varargin{ 1 } ) ||  ...
~strcmp( varargin{ 1 }, 'importToDict' )
syntaxCorrect = false;
end 
elseif length( varargin ) == 2
if ~ischar( varargin{ 1 } ) ||  ...
( ( ~strcmp( varargin{ 1 }, 'import_all' ) ||  ...
~strcmp( varargin{ 2 }, 'TREE' ) && ~strcmp( varargin{ 2 }, 'LIST' ) ) &&  ...
( ~strcmp( varargin{ 1 }, 'export_all' ) ||  ...
~strcmp( varargin{ 2 }, 'TREE' ) && ~strcmp( varargin{ 2 }, 'LIST' ) ) &&  ...
( ~strcmp( varargin{ 1 }, 'clear_all' ) ||  ...
~strcmp( varargin{ 2 }, 'TREE' ) && ~strcmp( varargin{ 2 }, 'LIST' ) ) &&  ...
( ~strcmp( varargin{ 1 }, 'saveToSource' ) ||  ...
~isa( varargin{ 2 }, 'Simulink.ModelWorkspace' ) ) &&  ...
( ~strcmp( varargin{ 1 }, 'export_selected' ) || ~isa( varargin{ 2 }, 'cell' ) ) )
syntaxCorrect = false;
end 
else 
syntaxCorrect = false;
end 

if ~syntaxCorrect
MSLDiagnostic( 'Simulink:dialog:WorkspaceCalledByExternal' ).reportAsWarning;
return ;
end 

action = varargin{ 1 };
if strcmp( action, 'export_selected' )
varnamelist = varargin{ 2 };
else 
varnamelist = {  };
end 

try 
if strcmp( action, 'import_all' ) ||  ...
strcmp( action, 'importToDict' )

recognizedFileType = [ DAStudio.message( 'Simulink:dialog:WorkspaceRecognizedFileFormat' ), ' (*.mat, *.m)' ];
[ filename, pathname ] = uigetfile( { '*.mat;*.m', recognizedFileType;'*.mat', 'MAT-files (*.mat)';'*.m', 'MATLAB-files (*.m)' },  ...
DAStudio.message( 'Simulink:dialog:WorkspaceImportFileDialogName' ) );
if ( isnumeric( filename ) && filename == 0 ) || ( isnumeric( pathname ) && pathname == 0 )
return ;
else 

[ ~, ~, ext ] = fileparts( filename );
if strcmp( ext, '.m' ) == 0 && strcmp( ext, '.mat' ) == 0
DAStudio.error( 'Simulink:dialog:WorkspaceCannotImportFromNonMATMATLABFile', filename );
end 
end 


if strcmp( action, 'import_all' )
loadfromfile( pathname, filename, '', '' );
else 
loadfromfile( pathname, filename, varargin{ 2 }, varargin{ 3 } );
end 

elseif strcmp( action, 'export_all' ) || strcmp( action, 'export_selected' )

recognizedFileType = [ DAStudio.message( 'Simulink:dialog:WorkspaceRecognizedFileFormat' ), ' (*.mat, *.m)' ];
[ filename, pathname ] = uiputfile( { '*.mat;*.m', recognizedFileType;'*.mat', 'MAT-files (*.mat)';'*.m', 'MATLAB-files (*.m)' },  ...
DAStudio.message( 'Simulink:dialog:WorkspaceExportFileDialogName' ) );
if ( isnumeric( filename ) && filename == 0 ) || ( isnumeric( pathname ) && pathname == 0 )
return ;
else 

[ ~, ~, ext ] = fileparts( filename );
if strcmp( ext, '.m' ) == 0 && strcmp( ext, '.mat' ) == 0
DAStudio.error( 'Simulink:dialog:WorkspaceCannotImportFromNonMATMATLABFile', filename );
end 
end 

if exist( [ pathname, filename ], 'file' ) ~= 2

savetofile( pathname, filename, 'create', varnamelist, false );
else 

saveoption = slprivate( 'slsaveVarsUserOptionDialog' );
if ~isempty( saveoption )

savetofile( pathname, filename, saveoption, varnamelist, false );
end 
end 

elseif strcmp( action, 'clear_all' )

msg = DAStudio.message( 'Simulink:dialog:WorkspaceVariableClearConfirmation' );
title = DAStudio.message( 'Simulink:dialog:WorkspaceVariableClearMsgBoxTitle' );
r = questdlg( msg, title, getString( message( 'Simulink:dialog:DCDOK' ) ), getString( message( 'Simulink:dialog:SfunCancel' ) ), getString( message( 'Simulink:dialog:SfunCancel' ) ) );
if strcmp( r, getString( message( 'Simulink:dialog:DCDOK' ) ) ) > 0

clearwsvariables;
end 

elseif strcmp( action, 'saveToSource' )

hws = varargin{ 2 };


if ~isempty( hws.LoadedSourceFileFullName )

[ pathname, filenameonly, ext ] = fileparts( hws.LoadedSourceFileFullName );
else 

[ pathname, filenameonly, ext ] = fileparts( hws.FileName );
if isempty( pathname )

pathname = pwd;
else 
is_aDir = ~isempty( dir( pathname ) );
if ~is_aDir

DAStudio.error( 'Simulink:Data:WksFolderNotExist', [ pathname, filenameonly, ext ] );
else 
is_relativeDir = ~isempty( dir( [ pwd, filesep, pathname ] ) );
if is_relativeDir

pathname = [ pwd, filesep, pathname ];
end 
end 
end 
end 
pathname = strcat( pathname, filesep );

if strcmp( ext, '' )
ext = '.mat';
end 

filename = [ filenameonly, ext ];
if exist( [ pathname, filename ], 'file' ) ~= 2

savetofile( pathname, filename, 'create', {  }, true );
else 

saveoption = slprivate( 'slsaveVarsUserOptionDialog', 'UserData', 'append' );
if ~isempty( saveoption )

savetofile( pathname, filename, saveoption, {  }, true );
end 
end 
else 
assert( false, 'unsupported action' );
end 
catch e
errordlg( e.message, DAStudio.message( 'Simulink:dialog:WorkspaceErrorMessageBoxTitle' ) );
end 




function loadfromfile( pathname, filename, dictionaryConnection, dictionaryScope )


[ ~, filenameonly, ext ] = fileparts( filename );
if isempty( filenameonly ) || ( ~strcmp( ext, '.m' ) && ~strcmp( ext, '.mat' ) )
DAStudio.error( 'Simulink:dialog:WorkspaceCannotImportFromNonMATMATLABFile', filename );
elseif strcmp( ext, '.m' ) && ~isvarname( filenameonly )
DAStudio.error( 'Simulink:dialog:WorkspaceCannotImportFromFileWithInvalidMATLABFileName', filename );
end 


if strcmp( ext, '.mat' )
if exist( [ pathname, filenameonly, '.m' ], 'file' ) == 2

lineno = isMATFileUsedByMFile( [ pathname, filenameonly, '.m' ], filename );
if lineno > 0
msg = DAStudio.message( 'Simulink:dialog:WorkspaceMATLABFileLoadingConfirmation',  ...
[ filenameonly, '.mat' ], [ filenameonly, '.m' ] );
title = DAStudio.message( 'Simulink:dialog:WorkspaceMATLABFileLoadingConfirmationTitle' );
r = questdlg( msg, title, getString( message( 'Simulink:dialog:DCDOK' ) ), getString( message( 'Simulink:dialog:SfunCancel' ) ), getString( message( 'Simulink:dialog:SfunCancel' ) ) );
if ~strcmp( r, getString( message( 'Simulink:dialog:DCDOK' ) ) )
return ;
end 
end 
end 
end 


if isempty( dictionaryConnection )

[ cwsname, mdlname ] = getWSType;
if ~strcmp( cwsname, 'Base Workspace' ) && ~strcmp( cwsname, 'Model Workspace' )
DAStudio.error( 'Simulink:dialog:WorkspaceSupportOnlyBaseAndModelWorkspace' );
end 


varnames = getAllWSVariables( mdlname );


if strcmp( ext, '.m' )
cmd = [ filenameonly, ';' ];
else 
cmd = [ 'load(''', filenameonly, '.mat'');' ];
end 

try 

[ cflist, noncflist ] = loadAndCheckNameConfliction( varnames, pathname, cmd );
catch me_load
DAStudio.error( 'Simulink:dialog:WorkspaceCannotLoadFromFile', [ pathname, filename ], me_load.message );
end 

isPartialLoad = false;
if ~isempty( cflist.varnames )

if isempty( noncflist.varnames )

msg = DAStudio.message( 'Simulink:dialog:WorkspaceVariableReplacementConfirmationAllVars' );
title = DAStudio.message( 'Simulink:dialog:WorkspaceVariableReplacementMsgBoxTitle' );
r = questdlg( msg, title, getString( message( 'Simulink:dialog:DCDOK' ) ), getString( message( 'Simulink:dialog:SfunCancel' ) ), getString( message( 'Simulink:dialog:SfunCancel' ) ) );
if strcmp( r, getString( message( 'Simulink:dialog:DCDOK' ) ) )

isPartialLoad = false;
else 
return ;
end 
else 


varcflistStr = getVarNamesInOneStr( cflist.varnames, false );

if length( cflist.varnames ) == 1
msg = DAStudio.message( 'Simulink:dialog:WorkspaceVariableReplacementConfirmation', cflist.varnames{ 1 } );
else 
msg = DAStudio.message( 'Simulink:dialog:WorkspaceVariableReplacementConfirmationpl', num2str( length( cflist.varnames ) ), varcflistStr );
end 
title = DAStudio.message( 'Simulink:dialog:WorkspaceVariableReplacementMsgBoxTitle' );
r = questdlg( msg, title, getString( message( 'Simulink:dialog:DCDOK' ) ), getString( message( 'Simulink:dialog:SfunCancel' ) ), getString( message( 'Simulink:dialog:SfunCancel' ) ) );
if ~strcmp( r, getString( message( 'Simulink:dialog:DCDOK' ) ) )
return ;
end 
end 
end 


if ~isPartialLoad && isempty( cflist.varnames ) && isempty( noncflist.varnames )

uiwait( warndlg( DAStudio.message( 'Simulink:dialog:WorkspaceNoVariablesInFile', filename ),  ...
DAStudio.message( 'Simulink:dialog:WorkspaceNoVariablesInFileWarnDlgTitle' ), 'modal' ) );
return ;
elseif isPartialLoad && ~isequal( cwsname, 'Dictionary' )

assert( false, 'partial load is currently not supported' );
end 


if strcmp( cwsname, 'Base Workspace' )
if ~isPartialLoad

assignVariablesToWS( noncflist, [  ] );
assignVariablesToWS( cflist, [  ] );
else 
assert( false, 'partial load is currently not supported' );

end 
elseif strcmp( cwsname, 'Model Workspace' )
hws = get_param( mdlname, 'ModelWorkspace' );
if isempty( hws )
DAStudio.error( 'Simulink:dialog:WorkspaceCannotGetModelWorkspace', mdlname );
else 
if ~isPartialLoad

assignVariablesToWS( noncflist, hws );
assignVariablesToWS( cflist, hws )
else 
assert( false, 'partial load is currently not supported' );

end 
end 
else 
DAStudio.error( 'Simulink:dialog:WorkspaceSupportOnlyBaseAndModelWorkspace' );
end 

else 
cwsname = 'Dictionary';%#ok
Simulink.dd.doDictionaryImport( dictionaryConnection, dictionaryScope, [ pathname, filename ] );
end 








function savetofile( pathname, filename, option, varnames, isMdlSaveToSource )



[ ~, filenameonly, ext ] = fileparts( filename );
if isempty( filenameonly ) || ( ~strcmp( ext, '.m' ) && ~strcmp( ext, '.mat' ) )
DAStudio.error( 'Simulink:dialog:WorkspaceCannotImportFromNonMATMATLABFile', filename );
end 


if strcmp( ext, '.m' )
if exist( [ pathname, filenameonly, '.mat' ], 'file' ) == 2

lineno = 0;
if exist( [ pathname, filenameonly, '.m' ], 'file' ) == 2
lineno = isMATFileUsedByMFile( [ pathname, filenameonly, '.m' ], [ filenameonly, '.mat' ] );
end 
if lineno == 0
msg = DAStudio.message( 'Simulink:dialog:WorkspaceMATFileRemoveReplacementConfirmation',  ...
[ filenameonly, '.m' ], [ filenameonly, '.mat' ] );
title = DAStudio.message( 'Simulink:dialog:WorkspaceMATFileRemoveReplacementConfirmationTitle' );
r = questdlg( msg, title, getString( message( 'Simulink:dialog:yesLabel' ) ), getString( message( 'Simulink:dialog:SfunCancel' ) ), getString( message( 'Simulink:dialog:SfunCancel' ) ) );
if strcmp( r, getString( message( 'Simulink:dialog:SfunCancel' ) ) )
return ;
end 
existingMatFile = 1;
else 
existingMatFile = 2;
end 
else 
existingMatFile = 0;
end 
else 
if exist( [ pathname, filenameonly, '.m' ], 'file' ) == 2

lineno = isMATFileUsedByMFile( [ pathname, filenameonly, '.m' ], filename );
if lineno > 0
msg = DAStudio.message( 'Simulink:dialog:WorkspaceMATLABFileExistingConfirmation',  ...
[ filenameonly, '.mat' ], [ filenameonly, '.m' ] );
title = DAStudio.message( 'Simulink:dialog:WorkspaceMATLABFileExistingConfirmationTitle' );
r = questdlg( msg, title, getString( message( 'Simulink:dialog:yesLabel' ) ), getString( message( 'Simulink:dialog:SfunCancel' ) ), getString( message( 'Simulink:dialog:SfunCancel' ) ) );
if strcmp( r, getString( message( 'Simulink:dialog:SfunCancel' ) ) )
return ;
end 
end 
end 
end 



[ cwsname, mdlname ] = getWSType;
if strcmp( cwsname, 'Base Workspace' )
isBaseWS = true;
elseif strcmp( cwsname, 'Model Workspace' )
isBaseWS = false;
else 
DAStudio.error( 'Simulink:dialog:WorkspaceSupportOnlyBaseAndModelWorkspace' );
end 


if isempty( varnames )
isexportall = true;
else 
isexportall = false;
end 

varlist = '';
if ~( strcmp( ext, '.mat' ) && strcmp( option, 'update' ) )
if ~isempty( varnames )

if strcmp( ext, '.mat' )
varlist = [ ', ', getVarNamesInOneStr( varnames, true ) ];
elseif strcmp( ext, '.m' )
varlist = [ '{', getVarNamesInOneStr( varnames, true ), '}' ];
end 
end 
else 

if isempty( varnames )

varnames = getAllWSVariables( mdlname );
end 

vars_in_file = who( '-file', [ pathname, filename ] );
for k = 1:length( varnames )
if ismember( varnames{ k }, vars_in_file )
varlist = strcat( varlist, [ ', ''', varnames{ k }, '''' ] );
end 
end 

if isempty( varlist )
if isexportall

uiwait( warndlg( DAStudio.message( 'Simulink:dialog:WorkspaceFileNoNeedUpdate', [ filenameonly, '.mat' ] ),  ...
DAStudio.message( 'Simulink:dialog:WorkspaceFileNoNeedUpdateWarnDlgTitle' ), 'modal' ) );
else 

uiwait( warndlg( DAStudio.message( 'Simulink:dialog:WorkspaceFileNoNeedUpdateSelect', [ filenameonly, '.mat' ] ),  ...
DAStudio.message( 'Simulink:dialog:WorkspaceFileNoNeedUpdateWarnDlgTitle' ), 'modal' ) );
end 
return ;
end 

end 



fullfilename = [ pathname, filename ];
if strcmp( ext, '.m' )


if isexportall
cmd = sprintf( 'matlab.io.saveVariablesToScript(''%s'', ''SaveMode'', ''%s'');', fullfilename, option );
else 
cmd = sprintf( 'matlab.io.saveVariablesToScript(''%s'', %s, ''SaveMode'', ''%s'');', fullfilename, varlist, option );
end 


if ~isBaseWS
cmd = [ '[saveVarsTmp{1}, saveVarsTmp{2}] = ', cmd ];
end 

elseif strcmp( option, 'create' )

cmd = sprintf( 'save(''%s'' %s);', fullfilename, varlist );
elseif strcmp( option, 'append' )

cmd = sprintf( 'save(''%s'', ''-%s'' %s);', fullfilename, option, varlist );
else 

cmd = sprintf( 'save(''%s'', ''-append'' %s);', fullfilename, varlist );
end 


hwarn = waitbar( 0.1, DAStudio.message( 'Simulink:dialog:WorkspaceExportVariablesWaitBarMessage' ) );

cwd = pwd;
c = onCleanup( @(  )cd( cwd ) );

try 
varsinmat = {  };
if isBaseWS
if strcmp( ext, '.m' )
[ varsinm, varsinmat ] = evalin( 'base', cmd );
else 
evalin( 'base', cmd );
end 
else 

hws = get_param( mdlname, 'ModelWorkspace' );
if isempty( hws )
DAStudio.error( 'Simulink:dialog:WorkspaceCannotGetModelWorkspace', mdlname );
else 

mdl_dirty = get_param( mdlname, 'Dirty' );
mdlws_dirty = hws.isDirty;

hws.evalin( cmd );
if strcmp( ext, '.m' )
varsinm = hws.evalin( 'saveVarsTmp{1};' );
varsinmat = hws.evalin( 'saveVarsTmp{2};' );
hws.evalin( 'clear saveVarsTmp' );
end 

if isMdlSaveToSource

hws.isDirty = false;
else 

hws.isDirty = mdlws_dirty;
end 

set_param( mdlname, 'Dirty', mdl_dirty );
end 
end 

if ishghandle( hwarn )
waitbar( 1, hwarn );
close( hwarn );
end 

if strcmp( ext, '.m' )

if isempty( varsinm ) && isempty( varsinmat )
if isexportall

uiwait( warndlg( DAStudio.message( 'Simulink:dialog:WorkspaceFileNoNeedUpdate', [ filenameonly, '.m' ] ),  ...
DAStudio.message( 'Simulink:dialog:WorkspaceFileNoNeedUpdateWarnDlgTitle' ), 'modal' ) );
else 

uiwait( warndlg( DAStudio.message( 'Simulink:dialog:WorkspaceFileNoNeedUpdateSelect', [ filenameonly, '.m' ] ),  ...
DAStudio.message( 'Simulink:dialog:WorkspaceFileNoNeedUpdateWarnDlgTitle' ), 'modal' ) );
end 
else 


lineno = isMATFileUsedByMFile( fullfilename, [ filenameonly, '.mat' ] );
if lineno > 0
if existingMatFile == 0 && ~isempty( varsinmat )

uiwait( warndlg( DAStudio.message( 'Simulink:dialog:WorkspaceMATFileCreation',  ...
[ filenameonly, '.mat' ], [ filenameonly, '.m' ] ),  ...
DAStudio.message( 'Simulink:dialog:WorkspaceMATFileCreationWarnDlgTitle' ), 'modal' ) );


elseif existingMatFile == 2 && ~isempty( varsinmat )

uiwait( warndlg( DAStudio.message( 'Simulink:dialog:WorkspaceMATFileChanged',  ...
[ filenameonly, '.m' ], [ filenameonly, '.mat' ] ),  ...
DAStudio.message( 'Simulink:dialog:WorkspaceMATFileChangedWarnDlgTitle' ), 'modal' ) );
end 
else 

if existingMatFile == 2


uiwait( warndlg( DAStudio.message( 'Simulink:Data:SaveVarMATFileCleanup', [ filenameonly, '.mat' ] ),  ...
DAStudio.message( 'Simulink:dialog:WorkspaceMATFileCleanupWarnDlgTitle' ), 'modal' ) );
end 
end 
end 



cd( pathname );
clear( filenameonly );
end 

catch me_save
if ishghandle( hwarn );close( hwarn );end 
DAStudio.error( 'Simulink:dialog:WorkspaceCannotSaveToFile', [ pathname, filename ], me_save.message );
end 



function clearwsvariables


[ cwsname, mdlname ] = getWSType;






cmd = 'clear;';


try 
if strcmp( cwsname, 'Base Workspace' )
evalin( 'base', cmd );
elseif strcmp( cwsname, 'Model Workspace' )
hws = get_param( mdlname, 'ModelWorkspace' );
if isempty( hws )
DAStudio.error( 'Simulink:dialog:WorkspaceCannotGetModelWorkspace', mdlname );
else 
hws.evalin( cmd );
end 
else 
DAStudio.error( 'Simulink:dialog:WorkspaceSupportOnlyBaseAndModelWorkspace' );
end 
catch e
rethrow( e );
end 








function r = isMATFileUsedByMFile( mfilename, matfilenamewopath )

r = 0;
fp = fopen( mfilename, 'r' );
if fp <= 0
MSLDiagnostic( 'Simulink:dialog:WorkspaceCannotOpenReadMATLABFile', mfilename ).reportAsWarning;
return ;
end 

load_str = [ 'saveVarsMat = load(''', matfilenamewopath, ''')' ];
count = 1;
count_max = 10;
while 1
aline = fgetl( fp );
if count > count_max || ~ischar( aline )
break ;
else 
k = strfind( aline, load_str );
if ~isempty( k ) && isempty( strtrim( aline( 1:k - 1 ) ) )
r = count;
break ;
end 
end 
count = count + 1;
end 

fclose( fp );



function [ cws, mdl ] = getWSType
me = daexplr;
im = DAStudio.imExplorer( me );
ctreend = me.getTreeSelection;
assert( ~isempty( ctreend ) );

if isa( ctreend, 'DAStudio.WorkspaceNode' )

cws = ctreend.getFullName;

if strcmp( cws, 'Model Workspace' )
mdl = ctreend.getParent.getFullName;
elseif strcmp( cws, 'Base Workspace' )
mdl = '';
else 
assert( false, 'support only base and model workspaces' );
end 
elseif isa( ctreend, 'Simulink.Root' )

clistnd = im.getSelectedListNodes;
if ( numel( clistnd ) == 1 && strcmp( clistnd.getFullName, 'Base Workspace' ) )
cws = 'Base Workspace';
mdl = '';
else 
n_vars = numel( clistnd );
if strcmp( clistnd{ 1 }.getParent.getFullName, 'Base Workspace' )
cws = 'Base Workspace';
mdl = '';
for k = 2:n_vars
mdl_name = clistnd{ k }.getParent.getFullName;
assert( strcmp( mdl_name, 'Base Workspace' ) );
end 
else 

cws = 'Model Workspace';
mdl = clistnd{ 1 }.getParent.getParent.getFullName;
for k = 2:n_vars
mdl_name = clistnd{ k }.getParent.getParent.getFullName;
assert( strcmp( mdl_name, mdl ) );
end 
end 
end 
elseif isa( ctreend, 'Simulink.BlockDiagram' )

cws = 'Model Workspace';
mdl = ctreend.getFullName;
elseif isa( ctreend, 'Simulink.DataDictionaryScopeNode' )
cws = 'Model Workspace';
mdl = ctreend.getParent.getParent.getFullName;
else 
assert( false, 'support only base and model workspaces' );
end 










function varnames = getAllWSVariables( mdlname )
if isempty( mdlname )
varnames = evalin( 'base', 'who' );
else 

hws = get_param( mdlname, 'ModelWorkspace' );
mdl_dirty = get_param( mdlname, 'Dirty' );
mdlws_dirty = hws.isDirty;

varnames = evalin( hws, 'who' );

hws.isDirty = mdlws_dirty;
set_param( mdlname, 'Dirty', mdl_dirty );
end 



function [ conflictlist, nonconflictlist ] = loadAndCheckNameConfliction( varnames_ws, pathname, cmd )

conflictlist.varnames = {  };
conflictlist.varvalues = {  };
nonconflictlist.varnames = {  };
nonconflictlist.varvalues = {  };

cwd = pwd;
c = onCleanup( @(  )cd( cwd ) );


cd( pathname );


varlist = loadVarsFromFile( cmd );

for k = 1:length( varlist.name )
varname_file = varlist.name{ k };
varvalue_file = varlist.value{ k };
if ismember( varname_file, varnames_ws )
conflictlist.varnames{ end  + 1 } = varname_file;
conflictlist.varvalues{ end  + 1 } = varvalue_file;
else 
nonconflictlist.varnames{ end  + 1 } = varname_file;
nonconflictlist.varvalues{ end  + 1 } = varvalue_file;
end 
end 



function vars = loadVarsFromFile( cmd )
vars = loadVarsFromCallerWorkspaceIntoStruct( cmd );



function vars = loadVarsFromCallerWorkspaceIntoStruct( cmd )
evalin( 'caller', 'clear' );
evalin( 'caller', cmd );
vars.name = evalin( 'caller', 'who' );
vars.value = cell( size( vars.name ) );
for k = 1:length( vars.name )
vars.value{ k } = evalin( 'caller', vars.name{ k } );
end 


function listStr = getVarNamesInOneStr( varnames, entirelist )
listStr = '';
numofvars = length( varnames );
numofvarslimit = 5;
if entirelist

for k = 1:numofvars - 1
listStr = strcat( listStr, [ '''', varnames{ k }, ''', ' ] );
end 
if numofvars > 0
listStr = strcat( listStr, [ '''', varnames{ numofvars }, '''' ] );
end 
elseif numofvars <= numofvarslimit

for k = 1:numofvars - 1
listStr = strcat( listStr, [ varnames{ k }, ', ' ] );
end 
if numofvars > 0
listStr = strcat( listStr, [ varnames{ numofvars } ] );
end 
else 

for k = 1:numofvars
listStr = strcat( listStr, [ varnames{ k }, ', ' ] );
end 
listStr = strcat( listStr, ' ... ' );
end 



function assignVariablesToWS( varInfolist, hmdlws )
numofvars = length( varInfolist.varnames );
for k = 1:numofvars
if isempty( hmdlws )
assignin( 'base', varInfolist.varnames{ k }, varInfolist.varvalues{ k } );
else 
hmdlws.assignin( varInfolist.varnames{ k }, varInfolist.varvalues{ k } );
end 
end 


% Decoded using De-pcode utility v1.2 from file /tmp/tmpcLtz82.p.
% Please follow local copyright laws when handling this file.

