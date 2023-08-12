classdef View < handle


properties ( Constant, Hidden )

USER = 1;
PROJ = 2;
SET = 3;
ANY =  - 1;
STORAGE = { 'user', 'project', 'set' };


FULL = 1;
FULL_FLAT = 2;
FLAT_FILTERED_ONLY = 3;
FILTERED_ONLY = 4;
DISPLAY = { 'full', 'flat' };

EDITOR = '__slreq_standalone_editor__';
end 

properties ( Access = public )
name;
reqQuery;
linkQuery;




displayMode;


storage;



displaySettings;




hostArtifact;
end 

properties ( Transient )
dirty
lastAppliedReqFilter
lastAppliedLinkFilter
reqDataChanged = false;
end 

methods ( Access = public )
function this = View( name )
this.name = name;
this.displayMode = this.FILTERED_ONLY;
this.storage = this.USER;
this.hostArtifact = '';
this.dirty = true;
this.reqDataChanged = false;

this.displaySettings = containers.Map( 'KeyType', 'char', 'ValueType', 'any' );

this.reqQuery = slreq.query.ReqFilter(  );
this.linkQuery = slreq.query.LinkFilter(  );

s = slreq.gui.DisplaySetting( this.EDITOR );
this.displaySettings( this.EDITOR ) = s;
end 

function s = getLabel( this, withActiveMark )
R36
this
withActiveMark = true;
end 

nameChar = convertStringsToChars( this.name );
if this.isVanillaView
s = getString( message( 'Slvnv:slreq:FilteredDefaultViewLabel' ) );
elseif this.isSetView
r = slreq.find( 'type', 'ReqSet', 'Filename', this.hostArtifact );
if isempty( r )
s = nameChar;
else 
s = [ nameChar, ' (', r.Name, ')' ];
end 
else 
s = nameChar;
end 

if withActiveMark && this.isActive
s = [ char( 10003 ), s ];
end 
end 

function tf = needUpdate( this )
tf = this.isActive && (  ...
~isequal( this.lastAppliedReqFilter, this.reqQuery.getQuery ) ...
 || ~isequal( this.lastAppliedLinkFilter, this.linkQuery.getQuery ) ...
 || this.reqDataChanged );
end 

function tf = sameView( this, view )
tf = strcmp( this.name, view.name ) && this.storage == view.storage;
end 

function toggleHierarchy( this )
if this.displayMode == this.FULL_FLAT
this.setDisplayMode( this.FULL );
elseif this.displayMode == this.FLAT_FILTERED_ONLY
this.setDisplayMode( this.FILTERED_ONLY );
elseif this.displayMode == this.FULL
this.setDisplayMode( this.FULL_FLAT );
elseif this.displayMode == this.FILTERED_ONLY
this.setDisplayMode( this.FLAT_FILTERED_ONLY );
end 
end 
function toggleFiltered( this )
if this.displayMode == this.FULL_FLAT
this.setDisplayMode( this.FLAT_FILTERED_ONLY )
elseif this.displayMode == this.FLAT_FILTERED_ONLY
this.setDisplayMode( this.FULL_FLAT );
elseif this.displayMode == this.FULL
this.setDisplayMode( this.FILTERED_ONLY );
elseif this.displayMode == this.FILTERED_ONLY
this.setDisplayMode( this.FULL );
end 
end 
function tf = isHierarchy( this )
switch this.displayMode
case { this.FULL_FLAT, this.FLAT_FILTERED_ONLY }
tf = false;
otherwise 
tf = true;
end 
end 
function tf = isFilteredOnly( this )
switch this.displayMode
case { this.FILTERED_ONLY, this.FLAT_FILTERED_ONLY }
tf = true;
otherwise 
tf = false;
end 
end 

function tf = isActive( this )
vm = slreq.app.MainManager.getInstance.viewManager;
if this == vm.getCurrentView(  )
tf = true;
else 
tf = false;
end 
end 

function takeView( this, other, overwrite )

this.displayMode = other.displayMode;
this.reqQuery = other.reqQuery;
this.linkQuery = other.linkQuery;

ks = keys( other.displaySettings );
for i = 1:length( ks )
k = ks{ i };
d = other.displaySettings( k );

if this.displaySettings.isKey( k )
if overwrite
our = this.displaySettings( k );
our.takeSettings( d );
end 
else 
this.displaySettings( k ) = d;
end 
end 
end 

function d = getDisplaySettings( this, widget, shouldCreate )
R36
this
widget = this.EDITOR;
shouldCreate = false;
end 
if strcmp( widget, 'standalone' )
widget = this.EDITOR;
end 

d = [  ];
if isKey( this.displaySettings, widget )
d = this.displaySettings( widget );
elseif shouldCreate
d = slreq.gui.DisplaySetting( widget );
this.displaySettings( widget ) = d;
end 
end 

function newView = copyViewToSave( this )

newView = slreq.gui.View( this.name );
newView.storage = this.storage;
newView.displayMode = this.displayMode;
ks = keys( this.displaySettings );
for i = 1:length( ks )
k = ks{ i };
if ~this.displaySettings( k ).wasReset
newView.displaySettings( k ) = copy( this.displaySettings( k ) );
end 
end 
end 

function resetFor( this, target )
appmgr = slreq.app.MainManager.getInstance;
switch target
case 'all'

ks = keys( this.displaySettings );
for i = 1:length( ks )
k = ks{ i };
d = this.displaySettings( k );
if ~d.isEditor
this.displaySettings.remove( k );
else 
d.reset(  );
end 
end 

if ~isempty( appmgr.requirementsEditor )
appmgr.requirementsEditor.resetViewSettings(  );
end 
if ~isempty( appmgr.spreadsheetManager )
appmgr.spreadsheetManager.resetAllViews(  );
end 

case 'editor'
d = this.displaySettings( this.EDITOR );
d.reset(  );
if ~isempty( appmgr.requirementsEditor )
appmgr.requirementsEditor.resetViewSettings(  );
end 

otherwise 
try 
if isnumeric( target )
modelName = get_param( target, 'Name' );
else 
modelName = target;
end 
catch ex
error( message( 'Slvnv:slreq:InvalidTargetSpecified' ) );
end 
if isKey( this.displaySettings, modelName )
this.displaySettings.remove( modelName );
end 
if appmgr.hasEditor(  )


spObj = appmgr.getSpreadSheetObject( modelName );
if ~isempty( spObj )
spObj.resetViewSettings(  );
end 
end 
end 
end 

function deActivate( this, forView )

R36
this
forView = '';
end 
ds = values( this.displaySettings );
for i = 1:length( ds )
if isempty( forView ) || strcmp( forView, ds{ i }.viewName )
ds{ i }.deActivate(  );
end 
end 
end 

function setQuery( this, charOrCell, forReq )
R36
this
charOrCell
forReq = true
end 
if forReq
this.reqQuery.setQuery( charOrCell );
else 
this.linkQuery.setQuery( charOrCell );
end 
end 

function q = getQuery( this, forReq )
R36
this
forReq = true
end 
if forReq
q = this.reqQuery.query;
else 
q = this.linkQuery.query;
end 
end 

function tf = isVanillaView( this )
tf = ( strcmp( this.name, slreq.app.ViewManager.VANILA_VIEW ) ...
 && this.isUserView );
end 

function setStorage( this, storage )
this.storage = storage;
if this.storage == this.SET
end 
end 

function tf = isUserView( this )
tf = ( this.storage == this.USER );
end 

function tf = isProjectView( this )
tf = ( this.storage == this.PROJ );
end 

function tf = isSetView( this )
tf = ( this.storage == this.SET );
end 

function setDisplayMode( this, mode )
this.displayMode = mode;
editor = slreq.app.MainManager.getInstance.requirementsEditor;
if ~isempty( editor )
editor.reDraw(  );
end 

end 

function update( this, force )
R36
this
force = false
end 

if ~force && ~this.needUpdate(  )
return ;
end 

this.reqDataChanged = false;


this.applyFilter(  );

ds = values( this.displaySettings );
for i = 1:numel( ds )
if ~isempty( ds{ i }.dasReqRoot ) && isvalid( ds{ i }.dasReqRoot )
ds{ i }.dasReqRoot.update(  );
end 
if ~isempty( ds{ i }.dasLinkRoot ) && isvalid( ds{ i }.dasLinkRoot )
ds{ i }.dasLinkRoot.update(  );
end 
end 

slreq.app.MainManager.getInstance.refreshUI;
end 

function errmsg = getLastErrors( this )
if ~isempty( this.reqQuery.lastErrors )
errmsg.requirement = this.reqQuery.lastErrors{ end  }.message;
else 
errmsg.requirement = '';
end 
if ~isempty( this.linkQuery.lastErrors )
errmsg.link = this.linkQuery.lastErrors{ end  }.message;
else 
errmsg.link = '';
end 
end 

function activate( this )
this.applyFilter(  );

mgr = slreq.app.MainManager.getInstance;
viewObjs = mgr.getAllViewers(  );
if ~isempty( viewObjs )


ds = this.getDisplaySettings(  );
ds.activate(  );
end 

for i = 1:numel( viewObjs )
viewObj = viewObjs{ i };
if ~isa( viewObj, 'slreq.internal.gui.Editor' )
ds = this.getDisplaySettings( viewObj.sourceID, true );
ds.activate(  );
end 
viewObj.switchToCurrentView(  );
end 

 ...
 ...
 ...
 ...
 ...
 ...




 ...
 ...
 ...
 ...
 ...
 ...
 ...
 ...
 ...
end 
end 

methods ( Access = private )
function applyFilter( this )
editor = slreq.app.MainManager.getInstance.requirementsEditor;


this.lastAppliedReqFilter = this.reqQuery.getQuery(  );
result = this.reqQuery.apply(  );
if ~isempty( this.reqQuery.lastErrors )
editor.ShowSuggestion = true;
editor.SuggestionId = this.reqQuery.lastErrors{ end  }.id;
editor.SuggestionReason = this.reqQuery.lastErrors{ end  }.message;
editor.showNotification(  );
end 

all = this.reqQuery.findAll;

for i = 1:length( all )
all( i ).setFilterState( 'out', true );
end 

for i = 1:length( result )
result( i ).setFilterState( 'in', false );
end 


this.lastAppliedLinkFilter = this.linkQuery.getQuery(  );
result = this.linkQuery.apply(  );
if ~isempty( this.linkQuery.lastErrors )
editor.ShowSuggestion = true;
editor.SuggestionId = this.linkQuery.lastErrors{ end  }.id;
editor.SuggestionReason = this.linkQuery.lastErrors{ end  }.message;
editor.showNotification(  );
end 

all = this.linkQuery.findAll;

for i = 1:length( all )
all( i ).setFilterState( 'out' );
end 

for i = 1:length( result )
result( i ).setFilterState( 'in' );
end 
end 
end 


end 

% Decoded using De-pcode utility v1.2 from file /tmp/tmpNfeKIk.p.
% Please follow local copyright laws when handling this file.

