classdef ViewManager < handle

properties ( Constant, Hidden )
VANILA_VIEW = '__default_slreq_view__';
USER_FILE = 'slreqViewSettings_v2.mat';
SET_FILE = 'viewSettings.mat';
SET_PATH = 'slrequirements/viewSettings.mat';
PROJ_FILE = 'slreqViewSettings.mat';
DEFAULT_NAME = 'new view';
VERSION = 1;
SAVE_STRUCT = struct( 'version', slreq.app.ViewManager.VERSION,  ...
'curView', slreq.gui.View.empty(  ),  ...
 ...
'views', slreq.gui.View.empty(  ) );
end 

properties ( Access = private )
userFilePath = '';
views = slreq.gui.View.empty(  );
deletedSetViews = slreq.gui.View.empty(  );
currentView;


viewSettingsManager;
end 

properties ( Access = private )
ReqDataChangeListener;
end 

methods ( Static, Hidden )
function vm = get(  )
app = slreq.app.MainManager.getInstance;
if isempty( app.viewManager )
app.init;
end 
if isempty( app.viewManager )
error( message( 'Slvnv:slreq:FailedMainManagerInit' ) );
end 
vm = app.viewManager;
end 
end 

methods 
function this = ViewManager( viewSettingsManager )
this.viewSettingsManager = viewSettingsManager;
this.userFilePath = fullfile( prefdir, this.USER_FILE );

reqData = slreq.data.ReqData.getInstance(  );
this.ReqDataChangeListener = reqData.addlistener( 'ReqDataChange', @this.onReqDataChange );


if reqmgt( 'rmiFeature', 'FilteredView' )
this.readUserViews(  );
end 
if isempty( this.views ) || isempty( this.getView )
defaultView = slreq.gui.View( this.VANILA_VIEW );
this.views( end  + 1 ) = defaultView;

settings = this.readOldUserViews;
if ~isempty( settings )
this.setViewsFromOldSettings( defaultView, settings );
end 
end 


this.readProjectViews(  );

if isempty( this.currentView )
this.currentView = this.getView;
end 

if ~reqmgt( 'rmiFeature', 'FilteredView' )

this.currentView = this.getView(  );
end 

end 

function delete( this )
if ~isempty( this.ReqDataChangeListener )
delete( this.ReqDataChangeListener );
this.ReqDataChangeListener = [  ];
end 
end 

function tf = isVanillaActive( this )
tf = this.currentView == this.getView;
end 

function deActivate( this )
for i = 1:length( this.views )
this.views( i ).deActivate(  );
end 
end 

function tf = hasStorage( this, storage )
tf = exist( this.userFilePath, 'file' ) == 2;
end 

function refreshView( this, view )


R36
this
view = this.getCurrentView(  )
end 

mgr = slreq.app.MainManager.getInstance;
viewObjs = mgr.getAllViewers(  );
for i = 1:length( viewObjs )
viewObj = viewObjs{ i };

d = view.getDisplaySettings( viewObj.getViewSettingID, true );
dCopy = copy( d );
displaySetting = this.getDisplaySetting( viewObj );
this.takeOldSettings( displaySetting, d );
if ~isequal( d, dCopy )
view.dirty = true;
end 
end 
end 

function displaySetting = getDisplaySetting( this, viewObj )

if ~any( strcmp( viewObj.reqColumns, 'Index' ) ) ...
 || any( strcmp( viewObj.linkColumns, 'Index' ) )



rmiut.warnNoBacktrace( getString( message( 'Slvnv:slreq:InvalidColumnSetting' ) ) );
return ;
end 

displaySetting = struct(  ...
'isReqView', viewObj.isReqView );
displaySetting.reqColumns = viewObj.reqColumns;
displaySetting.linkColumns = viewObj.linkColumns;
displaySetting.reqSortInfo = viewObj.reqSortInfo;
displaySetting.linkSortInfo = viewObj.linkSortInfo;
[ reqColumnWidths, linkColumnWidths ] = viewObj.getColumnWidths(  );
displaySetting.reqColumnWidths = reqColumnWidths;
displaySetting.linkColumnWidths = linkColumnWidths;
displaySetting.displayChangeInformation = viewObj.displayChangeInformation;
[ displaySetting.ssWidth, displaySetting.ssHeight ] = viewObj.getSpreadSheetSize(  );

if isa( viewObj, 'slreq.gui.ReqSpreadSheet' )
studio = viewObj.getStudio;
if isvalid( viewObj.mComponent ) && studio.isComponentVisible( viewObj.mComponent )
displaySetting.ssDockPosition =  ...
studio.getComponentDockPosition( viewObj.mComponent );
end 
else 

displaySetting.ssDockPosition = 'Bottom';
end 

end 

function importViewSettings( this, viewSettingFile, overwriteExisting )
try 
tmp = load( viewSettingFile );
catch 
return ;
end 


ver = 0;
if isfield( tmp, 'data' )
ver = tmp.data.version;
end 
if ver == 0
this.setViewsFromOldSettings( this.getView, tmp.viewSettings );
else 
try 
for i = 1:length( tmp.data.views )
loadedView = tmp.data.views( i );
ourView = this.getView( loadedView.name, loadedView.storage );
if isempty( ourView )
this.views( end  + 1 ) = loadedView;
else 
ourView.takeView( loadedView, overwriteExisting );
end 
end 
catch 
error( 'not able to import viewSettins' );
end 
end 
this.viewSettingsManager.restoreAllViews(  );
end 

function exportViewSettings( this, filePath )
try 
data = this.SAVE_STRUCT;
data.curView = this.currentView;
data.views = this.views;




save( filePath, 'data' );
catch 
rmiut.warnNoBacktrace( getString( message( 'Slvnv:slreq:UnableToSave', filePath ) ) );
end 
end 

function vs = readProjectViews( this )
vs = [  ];
try 
proj = currentProject(  );
catch 
return ;
end 

projFile = findFile( proj, this.PROJ_FILE );
if isempty( projFile )
return ;
end 

vs = load( projFile.Path );
this.views = [ this.views, vs ];
end 

function ds = getCurrentSettings( this, widget, create )
R36
this
widget = slreq.gui.View.EDITOR
create = false;
end 
if ~isempty( this.currentView )
ds = this.currentView.getDisplaySettings( widget, create );
end 
end 

function deleteView( this, view, erase )
R36
this
view
erase = true
end 

if isempty( view ) || view.isVanillaView(  )
return ;
end 
for i = 1:length( this.views )
if this.views( i ) == view
if this.currentView == view
this.setVanilaAsCurrent(  );
end 

if ~view.isSetView
this.saveViews( view, erase );
delete( view );
else 
this.deletedSetViews( end  + 1 ) = view;
end 

this.views( i ) = [  ];
break ;
end 
end 
end 

function v = createView( this, name, storage, hostArtifact )
R36
this
name = ''
storage = slreq.gui.View.USER
hostArtifact = ''
end 

if isempty( name )
name = this.DEFAULT_NAME;
end 

switch storage
case slreq.gui.View.USER
vs = this.getUserViews;
case slreq.gui.View.PROJ
vs = this.getProjectViews;
case slreq.gui.View.SET

vs = [  ];
otherwise 
vs = slreq.gui.View.empty;
end 

i = 0;
while ~isempty( vs )
if any( strcmp( { vs.name }, name ) )
name = [ name, '_', int2str( i ) ];
else 
break ;
end 
i = i + 1;
end 


if storage == slreq.gui.View.SET
rset = slreq.find( 'type', 'ReqSet', 'filename', hostArtifact, '-or', 'name', hostArtifact );
if isempty( rset )
v = slreq.gui.View.empty;
error( message( 'Slvnv:slreq:ReqSetNeedToBeLoadedForFilterView', hostArtifact ) );
end 
end 

v = slreq.gui.View( name );
v.storage = storage;
if storage == slreq.gui.View.SET
v.hostArtifact = rset.Filename;
end 
this.views( end  + 1 ) = v;
end 

end 

methods 
function wipeAllViews( this )

v = this.getView(  );
v.resetFor( 'all' );
this.setVanilaAsCurrent(  );

for i = 1:length( this.views )
if ~this.views( i ).isVanillaView
this.views( i ).delete(  );
end 
end 
this.views = [ v ];
this.saveViews(  );
end 

function resetFor( this, target )

this.currentView.resetFor( target );
this.saveViews(  );
end 

function v = getCurrentView( this )
v = this.currentView;
end 

function v = setVanilaAsCurrent( this )
v = this.setCurrentViewByName( this.VANILA_VIEW );
end 

function v = setCurrentView( this, view )

this.refreshView(  );
if ~isempty( this.currentView ) && ~this.currentView.isSetView
this.saveViews( this.currentView );
end 

v = view;
if ~isempty( view )
if this.currentView == view
if slreq.app.MainManager.initialized(  )
this.currentView.activate(  );
this.refreshView( this.currentView );
end 
return ;
end 




if ~isempty( this.currentView )
this.refreshView( this.currentView );
this.currentView.deActivate;
end 
this.currentView = view;
slreq.app.MainManager.getInstance.clearSelectedObjectsUponDeletion( [  ], true );
this.currentView.activate(  );
end 
end 

function v = setCurrentViewByName( this, name, storage )
R36
this
name
storage = slreq.gui.View.ANY
end 
v = this.getView( name, storage );
v = this.setCurrentView( v );

end 

function v = setCurrentViewByIdx( this, idx )

v = this.views( idx );
this.setCurrentView( v );
end 

function vs = getAllViews( this )
vs = this.views;
end 

function tf = isValidView( this, view )
if isempty( view ) || ~isvalid( view ) || ~any( this.views == view )
tf = false;
else 
tf = true;
end 
end 

function vs = getViews( this, name, hostArtifact )
R36
this
name = ''
hostArtifact = '__any__'
end 
vs = slreq.gui.View.empty;
for i = 1:numel( this.views )
if ( isempty( name ) && strcmp( hostArtifact, '__any__' ) ) ...
 || ( strcmp( hostArtifact, '__any__' ) && strcmp( name, this.views( i ).name ) ) ...
 || ( isempty( name ) && strcmp( this.views( i ).hostArtifact, hostArtifact ) ) ...
 || ( strcmp( this.views( i ).name, name ) && strcmp( this.views( i ).hostArtifact, hostArtifact ) )
vs( end  + 1 ) = this.views( i );
end 
end 
end 

function v = getView( this, name, storage, views )
R36
this
name = this.VANILA_VIEW
storage = slreq.gui.View.USER
views = this.views;
end 
v = slreq.gui.View.empty(  );
for i = 1:length( views )
if strcmp( views( i ).name, name ) &&  ...
( storage == slreq.gui.View.ANY || views( i ).storage == storage )
v = views( i );
break ;
end 
end 
end 

function saveViewsForReqSet( this, reqSetFile, oldReqSetFile )

R36
this
reqSetFile
oldReqSetFile = reqSetFile
end 

this.clearDeletedSetViews( oldReqSetFile, true );


setViews = this.getSetViews( oldReqSetFile );
for i = 1:numel( setViews )
view = setViews( i );
if strcmp( reqSetFile, view.hostArtifact )
this.saveViews( view );
else 

view.hostArtifact = reqSetFile;


this.saveViews( view );
end 
end 
end 

function saveUserViews( this, erase )
R36
this
erase = false;
end 
this.saveViews( this.getUserViews, erase );
end 

function saveViews( this, views, erase )
R36
this
views = this.views;
erase = false;
end 

ev = slreq.gui.View.empty;
classifedView = struct( 'user', ev, 'set', ev, 'proj', ev );
for i = 1:length( views )
v = views( i );
if v == this.currentView
this.refreshView( v );
end 
switch v.storage
case v.USER
classifedView.user( end  + 1 ) = v;
case v.SET
classifedView.set( end  + 1 ) = v;
case v.PROJ
classifedView.proj( end  + 1 ) = v;
end 
end 

this.writeUserViews( classifedView.user, erase );
this.writeSetViews( classifedView.set, erase );

end 






function setViewsFromOldSettings( this, view, settings )
ks = keys( settings );
for i = 1:length( ks )
k = ks{ i };
if strcmp( k, 'standalone' )
nk = slreq.gui.View.EDITOR;
else 
nk = k;
end 
d = view.getDisplaySettings( nk, true );
s = settings( ks{ i } );
this.takeOldSettings( s, d );
end 
end 



function takeOldSettings( this, s, dispSettings )
dispSettings.reqColumns = s.reqColumns;
dispSettings.linkColumns = s.linkColumns;
dispSettings.reqSortInfo = s.reqSortInfo;
dispSettings.linkSortInfo = s.linkSortInfo;
if isfield( s, 'reqColumnWidths' )
dispSettings.reqColumnWidths = s.reqColumnWidths;
end 
if isfield( s, 'linkColumnWidths' )
dispSettings.linkColumnWidths = s.linkColumnWidths;
end 
if isfield( s, 'displayChangeInformation' )
dispSettings.displayChangeInformation = s.displayChangeInformation;
end 
dispSettings.reqActive = s.isReqView;
if isfield( s, 'ssDockPosition' )
dispSettings.spreadsheetDockPos = s.ssDockPosition;
end 
if isfield( s, 'ssWidth' )
dispSettings.spreadsheetWidth = s.ssWidth;
dispSettings.spreadsheetHeight = s.ssHeight;
end 
end 



function settings = getOldSettings( this, dispSettings )
settings = [  ];
if isempty( dispSettings )
return ;
end 
settings = struct;
settings.reqColumns = dispSettings.reqColumns;
settings.linkColumns = dispSettings.linkColumns;
settings.reqSortInfo = dispSettings.reqSortInfo;
settings.linkSortInfo = dispSettings.linkSortInfo;
settings.reqColumnWidths = dispSettings.reqColumnWidths;
settings.linkColumnWidths = dispSettings.linkColumnWidths;
settings.displayChangeInformation = dispSettings.displayChangeInformation;
settings.isReqView = dispSettings.reqActive;
settings.ssDockPosition = dispSettings.spreadsheetDockPos;
end 
end 

methods ( Access = private )
function clearDeletedSetViews( this, filepath, erase )
R36
this
filepath
erase = false;
end 

idx = true( size( this.deletedSetViews ) );
for i = 1:numel( this.deletedSetViews )
v = this.deletedSetViews( i );
if strcmp( v.hostArtifact, filepath )
if erase
this.saveViews( v, true );
end 
idx( i ) = false;
end 
end 
this.deletedSetViews = this.deletedSetViews( idx );
end 

function onReqDataChange( this, ~, eventInfo )
if ~reqmgt( 'rmiFeature', 'FilteredView' )
return ;
end 

switch eventInfo.type
case 'BeforeDeleteRequirement'
case 'ReqSet Loaded'
reqSet = eventInfo.eventObj;
this.readSetViews( reqSet.filepath );
case 'Before ReqSet Discarded'

case 'ReqSet Discarded'
reqSetPath = eventInfo.eventObj;
this.removeSetViews( reqSetPath );
this.clearDeletedSetViews( reqSetPath );
end 

if ~isempty( this.currentView )
this.currentView.reqDataChanged = true;
end 
end 

function removeSetViews( this, reqSetPath )
vs = this.getSetViews( reqSetPath );
for i = 1:length( vs )
this.deleteView( vs( i ), false );
end 
end 

function readSetViews( this, fileName )
package = slreq.opc.Package( fileName );
try 
if any( strcmp( package.getFileList, this.SET_FILE ) )

tName = tempname;
package.readFile( this.SET_FILE, tName );


vs = this.readViews( tName );
delete( tName );
for i = 1:length( vs )
vs( i ).hostArtifact = fileName;
end 
end 
end 
end 

function views = getUserViews( this )
views = slreq.gui.View.empty;
function tf = takeUserView( v )
tf = false;
if v.isUserView(  )
views( end  + 1 ) = v;
tf = true;
end 
end 
arrayfun( @takeUserView, this.views );
end 

function views = getProjectViews( this, name )
R36
this
name = '';
end 
views = slreq.gui.View.empty;
function tf = takeProjView( v )
tf = false;
if v.isProjectView(  ) && ( ~isempty( name ) || strcmp( v.name, name ) )
views( end  + 1 ) = v;
tf = true;
end 
end 
arrayfun( @takeProjView, this.views );
end 

function views = getSetViews( this, setPath )
R36
this
setPath = '';
end 
views = slreq.gui.View.empty;
function tf = takeSetView( v )
tf = false;
if v.isSetView(  ) && ( ~isempty( setPath ) || strcmp( v.hostArtifact, setPath ) )
views( end  + 1 ) = v;
tf = true;
end 
end 
arrayfun( @takeSetView, this.views );
end 

function s = readOldUserViews( this )
vsMgr = this.viewSettingsManager;
s = vsMgr.ViewSettings;

end 

function readUserViews( this )
views = this.readViews( this.userFilePath, true );
end 

function views = readViews( this, fileName, setCurrent )
R36
this
fileName
setCurrent = false
end 

views = slreq.gui.View.empty;

try 
tmp = load( fileName, '-mat' );;
catch 
return ;
end 
for i = 1:length( tmp.data.views )
tmp.data.views( i ).dirty = false;
end 
views = tmp.data.views;


vs = views( ~cellfun( @isempty, { views.name } ) );
if numel( views ) ~= numel( vs )
warning( 'views with empty name detected in file %s and ignored', fileName );
end 
this.views = [ this.views, vs ];

if ~setCurrent
return ;
end 

curView = tmp.data.curView;
if isempty( curView )
this.setVanilaAsCurrent;
else 
v = this.getView( curView.name, curView.storage );
if ~isempty( v ) && strcmp( curView.name, v.name ) && curView.storage == v.storage
this.setCurrentView( v );
else 
this.setVanilaAsCurrent(  );
end 
end 
end 

function eraseViews( this, filePath, views )
if isempty( views )
return ;
end 

try 
tmp = load( filePath, '-mat' );
data = tmp.data;


for i = 1:length( views )
existingViews = data.views;
for j = 1:length( existingViews )
if existingViews( j ).sameView( views( i ) )
data.views( j ) = [  ];
break ;
end 
end 
end 
catch 
end 
end 

function tf = writeViews( this, filePath, views, overwrite, erase )





R36
this
filePath
views
overwrite = false
erase = false
end 
tf = false;

if isempty( views )
return ;
end 


data = this.SAVE_STRUCT;
if ~overwrite
try 
tmp = load( filePath, '-mat' );
data = tmp.data;
catch 
end 
end 




idx = cellfun( @isempty, { data.views.name } );
if any( idx )
warning( 'views with empty name detected in %s and erased', filePath );
data.views = data.views( ~idx );
end 


for i = 1:length( views )
existingViews = data.views;
for j = 1:length( existingViews )
if existingViews( j ).sameView( views( i ) )
data.views( j ) = [  ];
break ;
end 
end 
if ~erase
data.views( end  + 1 ) = views( i );
end 
end 

try 
save( filePath, 'data', '-mat' );
tf = true;
catch 
rmiut.warnNoBacktrace( getString( message( 'Slvnv:slreq:UnableToSave', filePath ) ) );
end 

end 

function writeSetViews( this, views, erase )

vMap = containers.Map;
for i = 1:length( views )
v = views( i );
if vMap.isKey( v.hostArtifact )
vs = vMap( v.hostArtifact );
vs( end  + 1 ) = v;
else 
vs = [ v ];
end 
vMap( v.hostArtifact ) = vs;
end 

ks = keys( vMap );
vs = values( vMap );
for i = 1:length( ks )

reqSetPath = ks{ i };
viewsForSet = vs{ i };

tName = tempname;

package = slreq.opc.Package( reqSetPath );
try 
if any( strcmp( package.getFileList, this.SET_FILE ) )
package.readFile( this.SET_FILE, tName );
end 
catch ME
end 

if erase
this.writeViews( tName, viewsForSet, false, erase );
else 
this.writeViews( tName, viewsForSet );
end 


try 
if any( strcmp( package.getFileList, this.SET_FILE ) )
r = package.removeFile( this.SET_FILE );
if strcmp( r, 'fail' )
fprintf( 'removeFile %s failed\n', this.SET_FILE );
end 
end 
catch ME
fprintf( 'removeFile %s throw exception\n', this.SET_FILE );
end 

if isfile( tName )
package.addFile( tName, this.SET_PATH );
delete( tName );

for j = 1:length( viewsForSet )
viewsForSet( j ).dirty = false;
end 
end 
end 

end 

function writeUserViews( this, views, erase )
R36
this
views = [  ];
erase = false;
end 

data = this.SAVE_STRUCT;
data.curView = this.currentView;
if isempty( views )
data.views = this.views;
else 
data.views = views;
end 

if erase
r = this.writeViews( this.userFilePath, views, false, true );
else 
r = this.writeViews( this.userFilePath, views, false, false );
end 

if r
for i = 1:length( views )
views( i ).dirty = false;
end 
end 
end 

function tf = writeProjectViews( this )
tf = false;
return ;
try 
proj = currentProject(  );
catch 
return ;
end 
vs = this.getProjectViews( proj.Name );
try 
save( fullpath( proj.RootFolder, this.PROJ_FILE ), 'vs' );
addFile( proj, this.PROJ_FILE );
catch 
rmiut.warnNoBacktrace( getString( message( 'Slvnv:slreq:UnableToSave', this.PROJ_FILE ) ) );
tf = true;
end 
end 
end 

end 

% Decoded using De-pcode utility v1.2 from file /tmp/tmpx9BPmi.p.
% Please follow local copyright laws when handling this file.

