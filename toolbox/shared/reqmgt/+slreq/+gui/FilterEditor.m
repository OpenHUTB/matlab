classdef FilterEditor < handle
properties ( Constant )
checkMark = char( 10003 );
reqComment = strjoin( [ 
"% Filter Specification"
"%"
"% Filter specification should evaluate to a cell array of arguments that"
"% can be passed to slreq.find to match items within a requirement set."
"%"
"% Examples:"
"% {'ReqType', 'Functional'} % Functional requirements"
"% {'ReqType', 'Functional','CreatedBy','jlittle'} % Functional reqs"
"%                                                 % created by jlittle"
"%"
"{};"
 ], '\n' );
linkComment = strjoin( [ 
"% Filter Specification"
"%"
"% Filter specification should evaluate to a cell array of arguments that"
"% can be passed to slreq.find to match items within a requirement set."
"%"
"% Examples:"
"% {'LinkType', 'Relate'} % links of type Relate"
"%"
"{};"
 ], '\n' );

cols = 10;
listRows = 3;
editRows = 6;

preferredWidth = 600;
preferredFilterEditHeight = 210;
preferredListHeight = 150;

dlgTag = 'slreqFilterViewDlgTag';
viewListGroupTag = 'viewListGroupTag';
viewListTag = 'viewListTag';
newBtnTag = 'newBtnTag';
delBtnTag = 'delBtnTag';
reqFilterEditTag = 'reqFilterEditTag';
linkFilterEditTag = 'linkFilterEditTag';
reqTabTag = 'reqFilterTabTag';
linkTabTag = 'linkFilterTabTag';
filterTabsTag = 'filterEditorTabTag';
editGroupTag = 'editGroupTag';
nameEditTag = 'nameEditTag';
storageComboTag = 'storageComboTag';
rsetComboTag = 'reqsetComboTag';
end 

properties 
forReq;
viewMgr;


viewEntries;
viewEntryIndices;

reqSets;
reqSetNames;


newViews = slreq.gui.View.empty;
viewToSelect = [  ];
end 


properties ( SetObservable )
viewIndex;


storage = 'User';
name = '';
reqSet = '';
end 

methods ( Static )
function closeDlg(  )
tr = DAStudio.ToolRoot;
dialogs = tr.getOpenDialogs.find( 'dialogTag', slreq.gui.FilterEditor.dlgTag );
for dlg = dialogs( : )'
try 
delete( dlg );
catch ME %#ok<NASGU>
end 
end 
end 
end 

methods 
function varType = getPropDataType( this, varName )
switch varName
case { 'storage', 'reqSet' }
varType = 'enum';
otherwise 
varType = 'string';
end 
end 

function allowedVals = getPropAllowedValues( this, propName )
[ selectedView, isNew ] = this.getSelectedView;

allowedVals = {  };
switch propName
case 'storage'
if isNew
if isempty( this.reqSets )
allowedVals = { 'User' };
else 
allowedVals = { 'User', 'Requirement Set' };
end 
else 
if selectedView.storage == slreq.gui.View.USER
allowedVals = { 'User' };
else 
allowedVals = { 'Requirement Set' };
end 
end 
case 'reqSet'
if isNew
allowedVals = this.reqSetNames;
else 
allowedVals = { selectedView.name };
end 
end 
end 
end 

methods 

function this = FilterEditor( forReq )
this.reqSets = slreq.find( 'type', 'ReqSet' );
for i = 1:length( this.reqSets )
this.reqSetNames{ end  + 1 } = this.reqSets( i ).Name;
end 
if ~isempty( this.reqSets )
this.reqSet = this.reqSets( 1 ).Name;
end 

this.forReq = forReq;
this.viewMgr = slreq.app.MainManager.getInstance(  ).viewManager;
this.viewIndex = [  ];
this.getViewEntries( true );

end 

function getViewEntries( this, init )
R36
this
init = false
end 
this.viewEntries = {  };
this.viewEntryIndices = [  ];
views = this.viewMgr.getViews;
for i = 1:length( views )
if ~views( i ).isVanillaView(  )
this.viewEntries{ end  + 1 } = views( i ).getLabel(  );
this.viewEntryIndices( end  + 1 ) = i;
if ~isempty( this.viewToSelect ) && this.viewToSelect == views( i )
this.viewIndex = i;
this.viewToSelect = [  ];
elseif init && this.viewMgr.getCurrentView == views( i )
this.viewIndex = i;
end 
end 
end 
end 

function [ view, isNew ] = getSelectedView( this )
if isempty( this.viewIndex )
view = slreq.gui.View.empty(  );
isNew = false;
else 
views = this.viewMgr.getViews;
view = views( this.viewIndex );
isNew = ismember( view, this.newViews );
end 
end 

function dlgstruct = getDialogSchema( this, dlg )

this.getViewEntries(  );

dlgstruct.DialogTitle = getString( message( 'Slvnv:slreq:FilteredViewEditor' ) );
dlgstruct.StandaloneButtonSet = { 'OK' };

listGrp = this.getListGroup;

if isempty( this.viewIndex )
dlgstruct.LayoutGrid = [ this.listRows, this.cols ];
listGrp.RowSpan = [ 1, this.listRows ];listGrp.ColSpan = [ 1, this.cols ];
dlgstruct.Items = { listGrp };
else 
dlgstruct.LayoutGrid = [ this.listRows + this.editRows, this.cols ];
editGrp = this.getEditGroup;
listGrp.RowSpan = [ 1, this.listRows ];
editGrp.RowSpan = [ this.listRows + 1, this.listRows + this.editRows ];

listGrp.ColSpan = [ 1, this.cols ];
editGrp.ColSpan = [ 1, this.cols ];

dlgstruct.Items = { listGrp, editGrp };
end 

dlgstruct.CloseMethod = 'dlgCloseMethod';
dlgstruct.CloseMethodArgs = { '%dialog', '%closeaction' };
dlgstruct.CloseMethodArgsDT = { 'handle', 'string' };
dlgstruct.DialogTag = this.dlgTag;

dlgstruct.Sticky = true;


end 

function group = getListGroup( this )
group.Type = 'group';
group.Tag = this.viewListGroupTag;



viewList.Type = 'listbox';
viewList.Tag = this.viewListTag;
viewList.Name = getString( message( 'Slvnv:slreq:FilteredViewsLabel' ) );
viewList.Entries = this.viewEntries;
viewList.Values = this.viewEntryIndices;
viewList.Value = this.viewIndex;

viewList.Mode = 1;
viewList.DialogRefresh = 1;
viewList.ObjectMethod = 'viewListCallback';
viewList.MethodArgs = { '%dialog' };
viewList.ArgDataTypes = { 'handle' };
viewList.PreferredSize = [ this.preferredWidth, this.preferredListHeight ];



spacer = struct( 'Type', 'panel' );

newBtn = struct( 'Type', 'pushbutton' );
newBtn.Tag = this.newBtnTag;
newBtn.Name = getString( message( 'Slvnv:slreq:New' ) );
newBtn.ObjectMethod = 'newView';
newBtn.MethodArgs = { '%dialog' };
newBtn.ArgDataTypes = { 'handle' };
newBtn.DialogRefresh = 1;

delBtn = struct( 'Type', 'pushbutton' );
delBtn.Tag = this.delBtnTag;
delBtn.Name = getString( message( 'Slvnv:slreq:Delete' ) );
delBtn.ObjectMethod = 'delView';
delBtn.MethodArgs = { '%dialog' };
delBtn.ArgDataTypes = { 'handle' };
delBtn.DialogRefresh = 1;

btnPanel = struct( 'Type', 'panel' );
btnPanel.LayoutGrid = [ 1, 3 ];
spacer.RowSpan = [ 1, 1 ];spacer.ColSpan = [ 1, 1 ];
newBtn.RowSpan = [ 1, 1 ];newBtn.ColSpan = [ 2, 2 ];
delBtn.RowSpan = [ 1, 1 ];delBtn.ColSpan = [ 3, 3 ];
btnPanel.Items = { spacer, newBtn, delBtn };
btnPanel.ColStretch = [ 1, 0, 0 ];

group.LayoutGrid = [ 5, this.cols ];
viewList.RowSpan = [ 1, 4 ];viewList.ColSpan = [ 1, this.cols ];
btnPanel.RowSpan = [ 5, 5 ];btnPanel.ColSpan = [ 1, this.cols ];
group.Items = { viewList, btnPanel };
end 

function tabs = getEditTabs( this )
features = { 'SyntaxHilighting', 'TabCompletion', 'CodeAnalyzer' };

[ selectedView, isNew ] = this.getSelectedView(  );

reqFilterEdit.Tag = this.reqFilterEditTag;
reqFilterEdit.Type = 'matlabeditor';
reqFilterEdit.MatlabEditorFeatures = features;
reqFilterEdit.ObjectMethod = 'reqFilterChange';
reqFilterEdit.MethodArgs = { '%dialog' };
reqFilterEdit.ArgDataTypes = { 'handle' };
reqFilterEdit.Value = this.getFilterText( selectedView );
reqFilterEdit.PreferredSize = [ this.preferredWidth, this.preferredFilterEditHeight ];

linkFilterEdit.MatlabEditorFeatures = features;
linkFilterEdit.Tag = this.linkFilterEditTag;
linkFilterEdit.Type = 'matlabeditor';
linkFilterEdit.Value = this.getFilterText( selectedView, false );
linkFilterEdit.ObjectMethod = 'linkFilterChange';
linkFilterEdit.MethodArgs = { '%dialog' };
linkFilterEdit.ArgDataTypes = { 'handle' };
linkFilterEdit.PreferredSize = [ this.preferredWidth, this.preferredFilterEditHeight ];


tab1.Name = getString( message( 'Slvnv:slreq:RequirementsFilter' ) );
tab1.Tag = this.reqTabTag;
tab1.Items = { reqFilterEdit };

tab2.Name = getString( message( 'Slvnv:slreq:LinksFilter' ) );
tab2.Tag = this.linkTabTag;
tab2.Items = { linkFilterEdit };


tabs.Name = 'tabs';
tabs.Tag = this.filterTabsTag;
tabs.Type = 'tab';
tabs.LayoutGrid = [ 5, this.cols ];
tabs.Tabs = { tab1, tab2 };

end 

function group = getEditGroup( this )
group.Type = 'group';
group.Tag = this.editGroupTag;



[ selectedView, isNew ] = this.getSelectedView(  );
assert( ~isempty( selectedView ), 'selectedView cannot be empty!' );


nameEdit.Type = 'edit';
nameEdit.Tag = this.nameEditTag;
nameEdit.Name = getString( message( 'Slvnv:slreq:FilteredViewNameLabel' ) );
nameEdit.ObjectMethod = 'nameChange';
nameEdit.MethodArgs = { '%dialog' };
nameEdit.ArgDataTypes = { 'handle' };
nameEdit.DialogRefresh = 1;
nameEdit.Value = selectedView.name;

storageCombo.Type = 'combobox';
storageCombo.Tag = this.storageComboTag;
storageCombo.Name = getString( message( 'Slvnv:slreq:FilteredViewsStorageLabel' ) );
storageCombo.ObjectProperty = 'storage';
storageCombo.DialogRefresh = 1;
storageCombo.Mode = 1;
storageCombo.Enabled = isNew;
storageCombo.ObjectMethod = 'storageChange';
storageCombo.MethodArgs = { '%dialog' };
storageCombo.ArgDataTypes = { 'handle' };


rsetCombo.Type = 'combobox';
rsetCombo.Name = 'Select requirement set';
rsetCombo.Tag = this.rsetComboTag;
rsetCombo.Mode = 1;
rsetCombo.ObjectProperty = 'reqSet';
rsetCombo.Enabled = isNew;
rsetCombo.ObjectMethod = 'rsetChange';
rsetCombo.MethodArgs = { '%dialog' };
rsetCombo.ArgDataTypes = { 'handle' };


editTabs = this.getEditTabs;

if isNew || selectedView.storage == slreq.gui.View.SET
group.LayoutGrid = [ this.editRows, this.cols ];

nameEdit.RowSpan = [ 1, 1 ];nameEdit.ColSpan = [ 1, this.cols ];
storageCombo.RowSpan = [ 2, 2 ];storageCombo.ColSpan = [ 1, this.cols ];
rsetCombo.RowSpan = [ 3, 3 ];rsetCombo.ColSpan = [ 1, this.cols ];
editTabs.RowSpan = [ 4, this.editRows ];editTabs.ColSpan = [ 1, this.cols ];

if strcmp( this.storage, 'User' )

group.Items = { nameEdit, storageCombo, editTabs };
else 
group.Items = { nameEdit, storageCombo, rsetCombo, editTabs };
end 
else 
group.LayoutGrid = [ this.editRows, this.cols ];

nameEdit.RowSpan = [ 1, 1 ];nameEdit.ColSpan = [ 1, this.cols ];
storageCombo.RowSpan = [ 2, 2 ];storageCombo.ColSpan = [ 1, this.cols ];
editTabs.RowSpan = [ 3, this.editRows ];editTabs.ColSpan = [ 1, this.cols ];

group.Items = { nameEdit, storageCombo, editTabs };
end 

end 

function txt = getFilterText( this, view, forReq )
R36
this
view
forReq = true
end 
txt = '';
if isempty( view )
return ;
end 

if forReq
f = view.reqQuery.query;
if isempty( f )
f = this.reqComment;
end 
else 
f = view.linkQuery.query;
if isempty( f )
f = this.linkComment;
end 
end 

txt = f;
return ;
end 

function setFilterText( this, view, text, forReq )
if isempty( view )
return ;
end 


if forReq
 ...
 ...
 ...
 ...
 ...
 ...
view.reqQuery.setQuery( text );
else 
 ...
 ...
 ...
 ...
 ...
 ...
view.linkQuery.setQuery( text );
end 
view.dirty = true;
return ;
end 

function nameChange( this, dlg )
view = this.getSelectedView(  );
if isempty( view )
return ;
end 

newName = dlg.getWidgetValue( this.nameEditTag );
if isempty( newName )
msgbox( getString( message( 'Slvnv:slreq:FilteredViewNameEmpty' ) ),  ...
getString( message( 'Slvnv:slreq:FilteredViewEditor' ) ) );
dlg.setWidgetValue( this.nameEditTag, view.name );
return ;
end 
if nnz( strcmp( this.viewEntries, newName ) ) > 1
msgbox( getString( message( 'Slvnv:slreq:FilteredViewNameNotUnique', newName ) ),  ...
getString( message( 'Slvnv:slreq:FilteredViewEditor' ) ) );
return ;
end 
view.name = newName;
view.dirty = true;
end 

function storageChange( this, dlg )
view = this.getSelectedView(  );
if isempty( view )
return ;
end 

switch this.storage
case 'User'
view.storage = slreq.gui.View.USER;
case 'Requirement Set'
view.storage = slreq.gui.View.SET;
rs = slreq.find( 'type', 'ReqSet', 'name', this.reqSet );
if ~isempty( rs )
view.hostArtifact = rs.Filename;
end 
end 
view.dirty = true;
end 

function rsetChange( this, dlg )
view = this.getSelectedView(  );
if isempty( view )
return ;
end 

rs = slreq.find( 'type', 'ReqSet', 'name', this.reqSet );
view.hostArtifact = rs.Filename;
view.dirty = true;
end 

function reqFilterChange( this, dlg )
view = this.getSelectedView(  );
if isempty( view )
return ;
end 

this.setFilterText( view, dlg.getWidgetValue( this.reqFilterEditTag ), true );
end 

function linkFilterChange( this, dlg )
view = this.getSelectedView(  );
if isempty( view )
return ;
end 
this.setFilterText( view, dlg.getWidgetValue( this.linkFilterEditTag ), false );
end 

function newView( this, dlg )
v = this.viewMgr.createView(  );
this.newViews( end  + 1 ) = v;
this.viewToSelect = v;
end 

function delView( this, dlg )
view = this.getSelectedView(  );
if isempty( view )
return ;
end 
this.viewMgr.deleteView( view );
this.viewIndex = [  ];
end 

function viewListCallback( this, dlg )
this.viewIndex = dlg.getWidgetValue( this.viewListTag );
end 

function dlgCloseMethod( this, dlg, actionStr )
this.viewMgr.saveUserViews(  );


app = slreq.app.MainManager.getInstance;
vs = app.getAllViewers;
for i = 1:numel( vs )
if ~isa( vs{ i }, 'slreq.internal.gui.Editor' )
vs{ i }.updateToolbar(  );
end 
end 


this.viewMgr.getCurrentView.update(  );
end 
end 
end 

% Decoded using De-pcode utility v1.2 from file /tmp/tmpWr922a.p.
% Please follow local copyright laws when handling this file.

