classdef Designer < systemcomposer.internal.mixin.CenterDialog




properties ( SetObservable = true, Hidden, Access = protected )
TreeModel;
ProfileFilter;
end 

properties ( Dependent, SetAccess = protected, GetAccess = protected )
ProfileModels;
end 

properties ( Access = protected )
LastDialogPos = [  ];
CurrentTreeNode;
CurrentTreeSource;
StatusMsg = '';
StatusIsError = false;
CurrentPropertyRow;
SelectTableRow =  - 1;
TreeIDMap;
CachedProfileFilterList;
DescExpanded = false;
ShowInheritedStereotypeProperties = false;
DialogInstance;
ShowBuiltInDataProfiles = false;
ShowSoftwareElements = false;
metaConfig;
end 

properties 

Context = systemcomposer.internal.profile.internal.ProfileEditorContext.SystemComposer;
end 

properties ( Constant )
ALL = DAStudio.message( 'SystemArchitecture:ProfileDesigner:All' );
REFRESH = DAStudio.message( 'SystemArchitecture:ProfileDesigner:Refresh' );
end 

methods ( Access = protected )
function this = Designer(  )


this.resetUIState(  );
this.TreeIDMap = systemcomposer.internal.profile.internal.TreeNodeIDMap;
this.metaConfig = systemcomposer.internal.profile.MetaConfig( this );
end 

function resetUIState( this )
this.ProfileFilter = this.ALL;
this.CurrentTreeNode = '';
this.CurrentTreeSource = [  ];
this.CurrentPropertyRow = uint32.empty( 1, 0 );

this.setStatus( DAStudio.message( 'SystemArchitecture:ProfileDesigner:Ready' ) );
end 
end 

methods ( Static )
function obj = instance(  )


persistent instance
if isempty( instance ) || ~isvalid( instance )
instance = systemcomposer.internal.profile.Designer;
end 
obj = instance;
end 

function launch( options )
R36
options.ProfileToSelect{ mustBeTextScalar } = '';
options.SkipLicenseCheckout logical = false
options.Context systemcomposer.internal.profile.internal.ProfileEditorContext = systemcomposer.internal.profile.internal.ProfileEditorContext.SystemComposer
options.ShowBuiltInProfiles logical = false
end 

instance = systemcomposer.internal.profile.Designer.instance(  );

if ~options.SkipLicenseCheckout
instance.checkoutLicense(  );
end 

instance.Context = options.Context;
instance.ShowBuiltInDataProfiles = options.ShowBuiltInProfiles;

if isempty( instance.DialogInstance ) || ~ishandle( instance.DialogInstance )
instance.DialogInstance = DAStudio.Dialog( instance );
else 
instance.DialogInstance.show(  );
instance.DialogInstance.refresh(  );
end 


if ~isempty( options.ProfileToSelect )
instance.handleClickProfileBrowserNode( instance.DialogInstance, options.ProfileToSelect );
instance.DialogInstance.refresh(  );
end 
end 

function unload(  )


systemcomposer.internal.profile.Profile.unload;
instance = systemcomposer.internal.profile.Designer.instance(  );

if isa( instance.DialogInstance, 'DAStudio.Dialog' )
delete( instance.DialogInstance );
end 
delete( instance );
end 

function id = getID( fqn )






instance = systemcomposer.internal.profile.Designer.instance(  );
id = instance.TreeIDMap.get( fqn );
end 

function tf = showMathWorksProfiles( value )
persistent showMW
if isempty( showMW )
showMW = false;
end 
tf = showMW;
if nargin == 1
showMW = value;
end 
end 
end 

methods 
function title = getTitle( ~ )
title = DAStudio.message( 'SystemArchitecture:ProfileDesigner:AppName' );
end 

function descTitle = getDescTitle( ~ )
descTitle = DAStudio.message( 'SystemArchitecture:ProfileDesigner:AppName' );
end 

function descText = getDescText( this )
if this.DescExpanded
descText = DAStudio.message( 'SystemArchitecture:ProfileDesigner:AppDescriptionFull' );
else 
descText = DAStudio.message( 'SystemArchitecture:ProfileDesigner:AppDescriptionSnip' );
end 
end 

function profMdls = doGetProfileModels( this )
profMdls = [  ];
profs = systemcomposer.internal.profile.Profile.getProfilesInCatalog(  );
for prof = profs
if strcmp( prof.getName, 'systemcomposer' ) ||  ...
( isa( prof, 'sl.data.annotation.profile.DataProfile' ) )
continue ;
end 
if prof.isMathWorksProfile && ~this.showMathWorksProfiles(  )
continue ;
end 
model = mf.zero.getModel( prof );
profMdls = cat( 1, profMdls, model );
end 
end 

function profMdls = get.ProfileModels( this )
profMdls = doGetProfileModels( this );
end 

function schema = getDialogSchema( this )



this.TreeIDMap.prune(  );

descSchema = this.getDescriptionSchema(  );
descSchema.RowSpan = [ 1, 1 ];
descSchema.ColSpan = [ 1, 2 ];

toolbarSchema = this.getToolbarSchema(  );
toolbarSchema.RowSpan = [ 2, 2 ];
toolbarSchema.ColSpan = [ 1, 2 ];

browserSchema = this.getProfileBrowserSchema(  );
browserSchema.RowSpan = [ 3, 3 ];
browserSchema.ColSpan = [ 1, 1 ];

propSchema = this.getSelectedItemPropertiesSchema(  );
propSchema.RowSpan = [ 3, 3 ];
propSchema.ColSpan = [ 2, 2 ];

statusSchema = this.getStatusBarSchema(  );
statusSchema.RowSpan = [ 4, 4 ];
statusSchema.ColSpan = [ 1, 2 ];

panel.Type = 'panel';
panel.Tag = 'main_panel';
panel.Items = { descSchema, toolbarSchema, browserSchema, propSchema, statusSchema };
panel.LayoutGrid = [ 4, 2 ];
panel.RowStretch = [ 0, 0, 1, 0 ];
panel.ColStretch = [ 1, 2 ];

schema.DialogTitle = this.getTitle(  );
schema.DisplayIcon = this.resource( 'profileNode' );
schema.Items = { panel };
schema.DialogTag = 'system_composer_profile_designer';
schema.Source = this;
schema.SmartApply = true;
schema.HelpMethod = 'handleClickHelp';
schema.HelpArgs = {  };
schema.HelpArgsDT = {  };
schema.OpenCallback = @( dlg )this.handleOpenDialog( dlg );
schema.CloseMethod = 'handleCloseDialog';
schema.CloseMethodArgs = { '%dialog', '%closeaction' };
schema.CloseMethodArgsDT = { 'handle', 'char' };
schema.StandaloneButtonSet = { '' };
schema.MinMaxButtons = true;
schema.ShowGrid = false;
schema.DisableDialog = false;

end 

function handleOpenDialog( this, dlg )


if isempty( this.LastDialogPos )
this.positionDialog( dlg, [  ], [ 1200, 750 ] );
else 
dlg.position = this.LastDialogPos;
end 
end 

function handleCloseDialog( this, dlg, ~ )


if this.hasUnsavedProfiles(  )



response = questdlg(  ...
DAStudio.message( 'SystemArchitecture:ProfileDesigner:UnsavedProfilesQuestion' ),  ...
DAStudio.message( 'SystemArchitecture:ProfileDesigner:UnsavedProfilesTitle' ),  ...
DAStudio.message( 'SystemArchitecture:ProfileDesigner:Save' ),  ...
DAStudio.message( 'SystemArchitecture:ProfileDesigner:Discard' ),  ...
DAStudio.message( 'SystemArchitecture:ProfileDesigner:Ignore' ),  ...
DAStudio.message( 'SystemArchitecture:ProfileDesigner:Save' ) );
this.handleUnsavedProfiles( response, dlg );
end 
this.LastDialogPos = dlg.position;
end 

function handleDescExpandClick( this )



this.DescExpanded = ~this.DescExpanded;
end 

function handleUnsavedProfiles( this, response, dlg )

switch response
case DAStudio.message( 'SystemArchitecture:ProfileDesigner:Save' )
this.saveUnsavedProfiles(  );

case DAStudio.message( 'SystemArchitecture:ProfileDesigner:Discard' )

this.discardUnsavedProfiles(  );
otherwise 

end 
dlg.refresh(  );
end 

function handleClickHelp( this )

if this.Context == systemcomposer.internal.profile.internal.ProfileEditorContext.Requirements

helpview( fullfile( docroot, 'slrequirements', 'helptargets.map' ), 'define_profiles' );
else 
helpview( fullfile( docroot, 'systemcomposer', 'helptargets.map' ), 'define_profiles' );
end 
end 

function checkProfileHealth( this )


profile = this.CurrentTreeSource;
profile.checkHealth(  );
end 

function handleClickMovePropertyDown( this )
prop = this.getCurrentPropertyDefinitionInTable(  );
currentIdx = prop.p_Index;
txn = this.beginTransaction( prop );
prop.propertySet.moveProperty( currentIdx, currentIdx + 1 );
txn.commit;
this.SelectTableRow = this.CurrentPropertyRow + 1;
end 

function handleClickMovePropertyUp( this )
prop = this.getCurrentPropertyDefinitionInTable(  );
currentIdx = prop.p_Index;
txn = this.beginTransaction( prop );
prop.propertySet.moveProperty( currentIdx, currentIdx - 1 );
txn.commit;
this.SelectTableRow = this.CurrentPropertyRow - 1;
end 

function prop = getCurrentPropertyDefinitionInTable( this )
currNode = this.CurrentTreeSource;
if this.isPrototype( currNode )
propSet = currNode.propertySet;
elseif this.isPropertySet( currNode )
propSet = currNode;
end 
if isempty( propSet ) || isempty( this.CurrentPropertyRow )
prop = {  };
else 
prop = {  };
if ~isempty( propSet.properties.toArray )
prop = arrayfun( @( x )propSet.getPropertyByIndex( x ), this.CurrentPropertyRow );
end 
end 
end 

function yesno = isLastPropertyInTable( ~, prop )
if ~isempty( prop ) && ( numel( prop ) == 1 )
yesno = ( prop.propertySet.properties.Size == prop.p_Index + 1 );
else 
yesno = true;
end 
end 

function yesno = isFirstPropertyInTable( ~, prop )
if ~isempty( prop ) && ( numel( prop ) == 1 )
yesno = ( prop.p_Index == 0 );
else 
yesno = true;
end 
end 

function handleClickNewProfile( this )


newName = this.generateNewProfileName(  );
profile = systemcomposer.internal.profile.Profile.newProfile( newName );%#ok<NASGU>


if this.isFilteringProfilesByModelOrDD(  )
msg = DAStudio.message( 'SystemArchitecture:ProfileDesigner:CreatedProfileButFiltered', newName );
else 
msg = DAStudio.message( 'SystemArchitecture:ProfileDesigner:CreatedProfile', newName );
end 
this.setStatus( msg );
end 

function handleClickNewPrototype( this )


newName = this.generateNewPrototypeName(  );
profile = this.getCurrentProfile(  );
txn = this.beginTransaction( profile );
profile.addPrototype( newName );
txn.commit;
end 

function handleClickNewPropertySet( this )

newName = this.generateNewPropertySetName(  );
profile = this.getCurrentProfile(  );
txn = this.beginTransaction( profile );
profile.addPropertySet( newName );
txn.commit;
end 

function handleClickCloseProfile( this, dlg )


if ~( this.isProfileSelectedInBrowser(  ) )


return ;
end 
profile = this.CurrentTreeSource;


if this.hasUnsavedChanges( profile )
dp = DAStudio.DialogProvider;
qDlg = dp.questdlg(  ...
DAStudio.message( 'SystemArchitecture:ProfileDesigner:SaveProfileQuestion', profile.getName(  ) ),  ...
DAStudio.message( 'SystemArchitecture:ProfileDesigner:SaveProfileTitle' ),  ...
{ DAStudio.message( 'SystemArchitecture:ProfileDesigner:Save' ),  ...
DAStudio.message( 'SystemArchitecture:ProfileDesigner:Discard' ),  ...
DAStudio.message( 'SystemArchitecture:ProfileDesigner:Cancel' ) },  ...
DAStudio.message( 'SystemArchitecture:ProfileDesigner:Save' ),  ...
@( resp )handleResponse( resp, dlg ) );
this.positionDialog( qDlg, dlg );
else 

handleResponse(  ...
DAStudio.message( 'SystemArchitecture:ProfileDesigner:Discard' ),  ...
dlg );
end 

function handleResponse( confirm, dlg )
if strcmp( confirm, DAStudio.message( 'SystemArchitecture:ProfileDesigner:Save' ) )

this.handleClickSaveProfile( [  ], '', 'saveButtonAction' );

elseif strcmp( confirm, DAStudio.message( 'SystemArchitecture:ProfileDesigner:Cancel' ) )

return ;
end 


[ hasUsage, usages ] = this.profileHasOpenUsages( profile );
if hasUsage
dp = DAStudio.DialogProvider;
eDlg = dp.errordlg(  ...
DAStudio.message( 'SystemArchitecture:ProfileDesigner:ProfileHasOpenUsages',  ...
profile.getName(  ), strjoin( usages, ''', ''' ) ),  ...
DAStudio.message( 'SystemArchitecture:ProfileDesigner:CannotCloseProfile' ),  ...
true );
this.positionDialog( eDlg, dlg );
return ;
end 



if this.profileHasOpenUsagesInScrapArch( profile )
Simulink.SystemArchitecture.internal.ApplicationManager.clearScrapArchitecture;
end 


this.closeProfile( profile.getName(  ) );

dlg.refresh(  );
end 
end 

function handleClickDeletePrototype( this, dlg )


if ~( this.isPrototypeSelectedInBrowser(  ) )

return ;
end 
prototype = this.CurrentTreeSource;


dp = DAStudio.DialogProvider;
qDlg = dp.questdlg(  ...
DAStudio.message( 'SystemArchitecture:ProfileDesigner:ConfirmDeletePrototype', prototype.fullyQualifiedName ),  ...
DAStudio.message( 'SystemArchitecture:ProfileDesigner:ConfirmDeletePrototypeTitle' ),  ...
{ DAStudio.message( 'SystemArchitecture:ProfileDesigner:Delete' ),  ...
DAStudio.message( 'SystemArchitecture:ProfileDesigner:Cancel' ) },  ...
DAStudio.message( 'SystemArchitecture:ProfileDesigner:Cancel' ),  ...
@( resp )handleResponse( resp, prototype, dlg ) );
this.positionDialog( qDlg, dlg );

function handleResponse( confirm, prototype, dlg )
if strcmp( confirm, DAStudio.message( 'SystemArchitecture:ProfileDesigner:Delete' ) )

currProfile = this.getCurrentProfile(  );
this.CurrentTreeSource = currProfile;
this.CurrentTreeNode = currProfile.getName;
this.commitTransaction( prototype, @(  )prototype.destroy );
dlg.refresh(  );
end 
end 
end 

function handleClickDeletePropSet( this, dlg )


if ~( this.isPropertySetSelectedInBrowser(  ) )


return ;
end 
propSet = this.CurrentTreeSource;


dp = DAStudio.DialogProvider;
qDlg = dp.questdlg(  ...
DAStudio.message( 'SystemArchitecture:ProfileDesigner:ConfirmDeletePropertySet', propSet.fullyQualifiedName ),  ...
DAStudio.message( 'SystemArchitecture:ProfileDesigner:ConfirmDeletePropertySetTitle' ),  ...
{ DAStudio.message( 'SystemArchitecture:ProfileDesigner:Delete' ),  ...
DAStudio.message( 'SystemArchitecture:ProfileDesigner:Cancel' ) },  ...
DAStudio.message( 'SystemArchitecture:ProfileDesigner:Cancel' ),  ...
@( resp )handleResponse( resp, propSet, dlg ) );
this.positionDialog( qDlg, dlg );

function handleResponse( confirm, propSet, dlg )
if strcmp( confirm, DAStudio.message( 'SystemArchitecture:ProfileDesigner:Delete' ) )

currProfile = this.getCurrentProfile(  );
this.CurrentTreeSource = currProfile;
this.CurrentTreeNode = currProfile.getName;
this.commitTransaction( propSet, @(  )propSet.destroy );
dlg.refresh(  );
end 
end 
end 

function handleClickImportProfile( this, dlg )


[ fname, fpath ] = uigetfile( '*.xml',  ...
DAStudio.message( 'SystemArchitecture:ProfileDesigner:ImportProfileTitle' ) );
if ~ischar( fname )
return ;
end 

fullpath = fullfile( fpath, fname );
try 
m = systemcomposer.internal.profile.Profile.loadFromFile( fullpath );%#ok<NASGU>
catch me
dp = DAStudio.DialogProvider;
eDlg = dp.errordlg(  ...
DAStudio.message( 'SystemArchitecture:ProfileDesigner:InvalidProfileFile', me.message ),  ...
DAStudio.message( 'SystemArchitecture:ProfileDesigner:ErrorLoadingProfile' ),  ...
true );
this.positionDialog( eDlg, dlg );
return ;
end 
this.SelectTableRow = 0;


if this.isFilteringProfilesByModelOrDD(  )
msg = DAStudio.message( 'SystemArchitecture:ProfileDesigner:SuccessfullyImportedProfileButFiltered', fname );
else 
msg = DAStudio.message( 'SystemArchitecture:ProfileDesigner:SuccessfullyImportedProfile', fname );
end 
this.setStatus( msg );
end 

function handleClickSaveProfile( this, dlg, ~, actionTag, postSaveFcn )


if nargin < 5
postSaveFcn = [  ];
end 

profile = this.getCurrentProfile(  );
if isempty( profile )
return ;
end 

switch actionTag
case 'saveButtonAction'


statusMsg = DAStudio.message( 'SystemArchitecture:ProfileDesigner:SavedProfile', profile.getName );
[ profileIsInUse, modelsToSave ] = this.profileHasOpenUsages( profile );
if profileIsInUse
dp = DAStudio.DialogProvider;
qDlg = dp.questdlg(  ...
DAStudio.message( 'SystemArchitecture:ProfileDesigner:SaveProfileAndModelsQuestion', profile.getName(  ) ),  ...
DAStudio.message( 'SystemArchitecture:ProfileDesigner:SaveProfileTitle' ),  ...
{ DAStudio.message( 'SystemArchitecture:ProfileDesigner:SaveProfileAndModels' ),  ...
DAStudio.message( 'SystemArchitecture:ProfileDesigner:SaveProfileOnly' ),  ...
DAStudio.message( 'SystemArchitecture:ProfileDesigner:Cancel' ) },  ...
DAStudio.message( 'SystemArchitecture:ProfileDesigner:SaveProfileAndModels' ),  ...
@( resp )handleSaveResponse( resp, dlg, statusMsg, modelsToSave, postSaveFcn ) );
this.positionDialog( qDlg, dlg );
else 


handleSaveResponse(  ...
DAStudio.message( 'SystemArchitecture:ProfileDesigner:SaveProfileOnly' ),  ...
dlg, statusMsg, modelsToSave, postSaveFcn );
end 

case 'saveAsButtonAction'
this.profileSaveAs( profile, dlg, postSaveFcn );

case 'saveAllButtonAction'
this.saveUnsavedProfiles(  );
dlg.refresh(  );
this.setStatus( DAStudio.message( 'SystemArchitecture:ProfileDesigner:SavedAllProfiles' ) );

case 'exportToPreviousButtonAction'
this.handleClickExportProfile(  );

otherwise 
assert( false, 'Invalid action tag' );
end 

function handleSaveResponse( response, dlg, statusMsg, modelsToSave, postSaveFcn )

if nargin < 5
postSaveFcn = [  ];
end 

prf = this.getCurrentProfile(  );
switch response
case DAStudio.message( 'SystemArchitecture:ProfileDesigner:SaveProfileAndModels' )
statusMsg = DAStudio.message( 'SystemArchitecture:ProfileDesigner:SavedProfileAndModels', prf.getName );
case DAStudio.message( 'SystemArchitecture:ProfileDesigner:SaveProfileOnly' )
modelsToSave = {  };
otherwise 
return ;
end 


if ~isempty( prf.filePath )
s = this.profileSave( prf, '', dlg, postSaveFcn );
if s
return ;
end 
else 
this.profileSaveAs( prf, dlg, postSaveFcn );
end 


for idx = 1:length( modelsToSave )
[ ~, name, ext ] = fileparts( modelsToSave{ idx } );
if ~strcmpi( ext, '.sldd' )
save_system( name, 'SaveDirtyReferencedModels', true );
else 
ddConn = Simulink.data.dictionary.open( modelsToSave{ idx } );
ddConn.saveChanges(  );
end 
end 

if ~isempty( dlg )
dlg.refresh(  );
end 
this.setStatus( statusMsg );
end 
end 

function handleClickImportProfileIntoModelorDD( this, dlg, ~, fileName )




[ isModel, modelOrDDName ] = this.isModelContext( fileName );

if strcmp( modelOrDDName, 'select_action' ) ||  ...
strcmp( modelOrDDName, 'none_action' )
return ;
end 

profile = this.getCurrentProfile(  );
profileName = profile.getName(  );
profileDirty = this.hasUnsavedChanges( profile );

dp = DAStudio.DialogProvider;

if isModel

if this.isArchModelOpen( modelOrDDName )




if this.modelHasProfileAlready( profile, modelOrDDName )


mDlg = dp.msgbox(  ...
DAStudio.message( 'SystemArchitecture:ProfileDesigner:ModelAlreadyHasProfile', profileName, modelOrDDName ),  ...
DAStudio.message( 'SystemArchitecture:ProfileDesigner:ModelOrDDAlreadyHasProfileTitle' ), true );
this.positionDialog( mDlg, dlg );
else 



if profileDirty
question = DAStudio.message( 'SystemArchitecture:ProfileDesigner:SaveAndImportProfileIntoModelQuestion', profileName, modelOrDDName );
yes = DAStudio.message( 'SystemArchitecture:ProfileDesigner:SaveAndImport' );
else 
question = DAStudio.message( 'SystemArchitecture:ProfileDesigner:ImportProfileIntoModelQuestion', profileName, modelOrDDName );
yes = DAStudio.message( 'SystemArchitecture:ProfileDesigner:Import' );
end 
title = DAStudio.message( 'SystemArchitecture:ProfileDesigner:ImportProfileIntoModelTitle' );
cancel = DAStudio.message( 'SystemArchitecture:ProfileDesigner:Cancel' );

qDlg = dp.questdlg(  ...
question, title, { yes, cancel }, yes,  ...
@( resp )handleResponse( resp, dlg, profileDirty, yes, fileName ) );
this.positionDialog( qDlg, dlg );
end 
end 
else 

if this.dictionaryHasProfileAlready( profileName, fileName )


mDlg = dp.msgbox(  ...
DAStudio.message( 'SystemArchitecture:ProfileDesigner:DictionaryAlreadyHasProfile', profileName, modelOrDDName ),  ...
DAStudio.message( 'SystemArchitecture:ProfileDesigner:ModelOrDDAlreadyHasProfileTitle' ), true );
this.positionDialog( mDlg, dlg );
else 

if profileDirty
question = DAStudio.message( 'SystemArchitecture:ProfileDesigner:SaveAndImportProfileIntoDictionaryQuestion', profileName, modelOrDDName );
yes = DAStudio.message( 'SystemArchitecture:ProfileDesigner:SaveAndImport' );
else 
question = DAStudio.message( 'SystemArchitecture:ProfileDesigner:ImportProfileIntoDictionaryQuestion', profileName, modelOrDDName );
yes = DAStudio.message( 'SystemArchitecture:ProfileDesigner:Import' );
end 
title = DAStudio.message( 'SystemArchitecture:ProfileDesigner:ImportProfileIntoDictionaryTitle' );
cancel = DAStudio.message( 'SystemArchitecture:ProfileDesigner:Cancel' );

qDlg = dp.questdlg(  ...
question, title, { yes, cancel }, yes,  ...
@( resp )handleResponse( resp, dlg, profileDirty, yes, fileName ) );
this.positionDialog( qDlg, dlg );
end 
end 

function handleResponse( confirm, dlg, dirty, allowMsg, mdlOrDDFileName )
prf = this.getCurrentProfile(  );
if strcmp( confirm, allowMsg )



import_fcn = @(  )this.importProfileIntoOpenModelOrDD( prf, mdlOrDDFileName );
if dirty
this.handleClickSaveProfile( [  ], [  ], 'saveButtonAction', import_fcn );
else 
import_fcn(  );
end 
end 
if ~isempty( dlg )
dlg.refresh(  );
end 
this.DialogInstance.refresh;
end 
end 

function handleProfileFilterChanged( this, ~, value )





cached_opts = this.CachedProfileFilterList;

opts = this.getProfileFilterList(  );

if isequal( opts, cached_opts )
new_value = value + 1;
else 
item = cached_opts{ value + 1 };

if ismember( item, opts )
new_value = find( strcmp( item, opts ) );
else 


new_value = 1;
end 
end 

selection = opts{ new_value };
if strcmpi( selection, this.REFRESH )
this.ProfileFilter = this.ALL;
else 
this.ProfileFilter = selection;
end 
end 

function handleClickExportProfile( this, ~, ~ )

currProfile = this.getCurrentProfile;
releases = { 'R2019b' };
[ fname, fpath, filterIndex ] = uiputfile( { '*.xml', 'Architecture 1.0/R2019b Profile (*.xml)' },  ...
'Export profile as...',  ...
currProfile.getName(  ) );
if isequal( fname, 0 ) || isequal( fpath, 0 )

return ;
end 
releaseName = releases{ filterIndex };
try 
mkdir( [ fpath, '/', releaseName ] );
catch ex
DAStudio.error( 'SystemArchitecture:ProfileDesigner:CannotExportFileToDisk', ex.message );
end 
fullPath = fullfile( fpath, releaseName, fname );
currProfile.exportToPrevious( releaseName, fullPath );
end 

function handleClickProfileBrowserNode( this, ~, value )


if isempty( this.ProfileModels )
this.resetUIState(  );
return ;
end 

this.setCurrentTreeNode( value );
if ( this.isPrototypeSelectedInBrowser(  ) )
proto = this.getPrototype( this.CurrentTreeNode );
this.SelectTableRow = this.CurrentPropertyRow;
if ( ~isempty( this.CurrentPropertyRow ) && ~isempty( proto.propertySet ) )








if ( isempty( proto.propertySet.properties.toArray ) )

this.SelectTableRow =  - 1;
this.CurrentPropertyRow = uint32.empty( 1, 0 );
end 
if ( proto.propertySet.properties.Size - 1 < this.CurrentPropertyRow )

this.SelectTableRow = double( proto.propertySet.properties.Size ) - 1;
this.CurrentPropertyRow = uint32( this.SelectTableRow );
end 

else 
if ( isempty( proto.propertySet ) || proto.propertySet.properties.Size == uint64( 0 ) )
this.SelectTableRow =  - 1;
this.CurrentPropertyRow = uint32.empty( 1, 0 );
else 



this.SelectTableRow = 0;
this.CurrentPropertyRow = 0;
end 
end 
end 
end 


function handlePrototypeBaseChange( this, dlg, value )


prototype = this.CurrentTreeSource;

entries = this.getBasePrototypeEntries(  );
value = value + 1;

txn = this.beginTransaction( prototype );
if value == 1

prototype.parent = systemcomposer.internal.profile.Prototype.empty;
else 
newBaseFQN = entries{ value };
newBase = this.getPrototype( newBaseFQN, '.' );
prototype.parent = newBase;

if this.isPrototypeType( newBase, 'Requirement' )
this.metaConfig.addMetaProperties( prototype, 'Requirement' );
elseif this.isPrototypeType( newBase, 'Link' )
this.metaConfig.addMetaProperties( prototype, 'Link' );
end 

end 
txn.commit(  );

dlg.refresh(  );
end 

function handlePrototypeTreeAppliesToChange( this, dlg, value )

value = strrep( value, '<all>', '' );
value = regexprep( value, '.+/', '' );

if strcmp( value, getString( message( 'SystemArchitecture:ProfileDesigner:ShowMore' ) ) )
this.ShowSoftwareElements = true;
dlg.refresh(  );
elseif strcmp( value, getString( message( 'SystemArchitecture:ProfileDesigner:ShowLess' ) ) )
this.ShowSoftwareElements = false;
dlg.refresh(  );
else 
prototype = this.CurrentTreeSource;
txn = this.beginTransaction( prototype );
prototype.setAppliesTo( value );
txn.commit;


dlg.expandTogglePanel( 'AppliesToTogglePanel', false );
end 
end 

function handlePrototypeAppliesToChange( this, ~, value )

prototype = this.CurrentTreeSource;
entries = this.getMetaclassEntries(  );
value = value + 1;

txn = this.beginTransaction( prototype );
if value == 1
prototype.setAppliesTo( '' );
else 
newBase = entries{ value };
this.metaConfig.addMetaProperties( prototype, newBase );
prototype.setAppliesTo( newBase );
end 
txn.commit;
end 

function handlePositioningOfDialogOnButtonClick( ~, pickerDlg, buttonPos )
defaultPos = pickerDlg.position;
offset = buttonPos( 3:4 ) / 2;


dlgPos = [ buttonPos( 1:2 ) + offset, defaultPos( 3 ), defaultPos( 4 ) ];



screen = get( 0, 'screensize' );

dlgXPos = dlgPos( 1 );
dlgYPos = dlgPos( 2 );
dlgW = dlgPos( 3 );
dlgH = dlgPos( 4 );

screenW = screen( 3 );
screenH = screen( 4 );











if ( dlgXPos > screenW )
if dlgXPos + dlgW > ( 2.5 * screenW )

dlgXPos = ( 2.5 * screenW ) - dlgW;
end 
else 
if dlgXPos + dlgW > screenW

dlgXPos = screenW - dlgW - 5;
end 
end 

if ( dlgYPos > screenH )
if dlgYPos + dlgH > ( 2.5 * screenH )

dlgYPos = ( 2.5 * screenH ) - dlgH;
end 
else 
if dlgYPos + dlgH > screenH

dlgYPos = screenH - dlgH - 5;
end 
end 

pickerDlg.position = [ dlgXPos, dlgYPos, dlgW, dlgH ];
pickerDlg.show(  );
end 

function handlePrototypeIconPickerClick( this, dlg )
iconPicker = systemcomposer.internal.profile.internal.PrototypeIconPicker( this, dlg );
pickerDlg = DAStudio.Dialog( iconPicker );

buttonPos = dlg.getWidgetPosition( 'prototypeIconPickerButton' );
this.handlePositioningOfDialogOnButtonClick( pickerDlg, buttonPos );
end 

function handlePrototypeIconSelected( this, dlg, value )
prototype = this.CurrentTreeSource;
txn = this.beginTransaction( prototype );
prototype.icon = value;
txn.commit;
dlg.refresh(  );
end 

function handleSelectNoIcon( this, dlg )
prototype = this.CurrentTreeSource;
txn = this.beginTransaction( prototype );
prototype.icon = systemcomposer.internal.profile.PrototypeIcon.empty( 0, 0 );
txn.commit;
dlg.refresh(  );
end 

function handleCustomPrototypeIconSelected( this, dlg, customIconPath )
prototype = this.CurrentTreeSource;
txn = this.beginTransaction( prototype );
prototype.setCustomIcon( customIconPath );
txn.commit;
dlg.refresh(  );
end 

function handlePrototypeLineColorPickerClick( this, dlg )
lineColorPicker = systemcomposer.internal.profile.internal.PrototypeLineColorPicker( this, dlg );
pickerDlg = DAStudio.Dialog( lineColorPicker );


buttonPos = dlg.getWidgetPosition( 'prototypeLineColorPickerButton' );
this.handlePositioningOfDialogOnButtonClick( pickerDlg, buttonPos );
end 

function handlePrototypeLineColorSelected( this, dlg, value )
assert( isinteger( value ) );
prototype = this.CurrentTreeSource;
txn = this.beginTransaction( prototype );
prototype.setConnectorLineColorInRGB( value );
txn.commit;
dlg.refresh(  );
end 

function handlePrototypeLineStylePickerClick( this, dlg )
lineStylePicker = systemcomposer.internal.profile.internal.PrototypeLineStylePicker( this, dlg );
pickerDlg = DAStudio.Dialog( lineStylePicker );


buttonPos = dlg.getWidgetPosition( 'prototypeLineStylePickerButton' );
this.handlePositioningOfDialogOnButtonClick( pickerDlg, buttonPos );
end 

function handlePrototypeLineStyleSelected( this, dlg, value )
prototype = this.CurrentTreeSource;
prototype.connectorLineStyle = value;
dlg.refresh(  );
end 

function handleCompPrototypeColorPickerClick( this, dlg )

colorPicker = systemcomposer.internal.profile.internal.PrototypeColorPicker( this, dlg );
pickerDlg = DAStudio.Dialog( colorPicker );


buttonPos = dlg.getWidgetPosition( 'prototypeColorPickerButton' );
this.handlePositioningOfDialogOnButtonClick( pickerDlg, buttonPos );
end 

function handlePrototypeColorSelected( this, dlg, value )
assert( isinteger( value ) );
prototype = this.CurrentTreeSource;
txn = this.beginTransaction( prototype );
prototype.setComponentHeaderColorInRGB( value );
txn.commit;
dlg.refresh(  );
end 

function handleEnumSelected( this, dlg, origIdx, propertyName, EnumName )
propSet = this.getCurrentPropertySet;
txn = this.beginTransaction( propSet );
if ~isempty( EnumName )
propSet.removeProperty( propertyName );
replacedProp = propSet.addEnumProperty( propertyName, EnumName );
propSet.moveProperty( replacedProp.p_Index, origIdx );
end 
txn.commit;
dlg.refresh(  );
end 

function handleStereotypeAbstractChange( this, ~, value )


stereotype = this.CurrentTreeSource;
txn = this.beginTransaction( stereotype );
stereotype.abstract = value;
txn.commit;
end 

function handleSelectPropertyInTable( this, dlg, tag )


this.CurrentPropertyRow = dlg.getSelectedTableRows( tag );
this.SelectTableRow = this.CurrentPropertyRow;



if isempty( this.CurrentPropertyRow )
propSet = this.getCurrentPropertySet;
if propSet.properties.Size > uint64( 0 )
this.CurrentPropertyRow = 0;
this.SelectTableRow = 0;
dlg.selectTableRow( 'propTable', 0 )
end 
end 
this.setMoveUpDownEnabledState( dlg );
end 

function setMoveUpDownEnabledState( this, dlg )





currentProp = this.getCurrentPropertyDefinitionInTable(  );
enableMoveUp = ~this.isFirstPropertyInTable( currentProp );
enableMoveDown = ~this.isLastPropertyInTable( currentProp );
enableDelete = ~isempty( currentProp );

dlg.setEnabled( 'moveUp', enableMoveUp );
dlg.setEnabled( 'moveDown', enableMoveDown );
dlg.setEnabled( 'deleteProp', enableDelete );
end 

function handleClickAddProperty( this )


currSrc = this.CurrentTreeSource;
newPropName = this.generateNewPropertyName(  );
txn = this.beginTransaction( currSrc );
currSrc.addProperty( newPropName, 'string' );
txn.commit;
if this.isPrototype( currSrc )
this.SelectTableRow = currSrc.propertySet.properties.Size - 1;
else 
this.SelectTableRow = currSrc.properties.Size - 1;
end 
end 

function handleClickDeleteProperty( this )



propSet = this.getCurrentPropertySet;
props = propSet.properties.toArray;


txn = this.beginTransaction( propSet );
for idx = this.CurrentPropertyRow
propSet.removeProperty( props( idx + 1 ).getName );
end 
txn.commit(  );


if propSet.properties.Size == 0
this.SelectTableRow =  - 1;
this.CurrentPropertyRow = uint32.empty( 1, 0 );
else 
deletedRow = double( min( this.CurrentPropertyRow ) );
maxRow = double( propSet.properties.Size ) - 1;
this.SelectTableRow = min( deletedRow, maxRow );
this.CurrentPropertyRow = this.SelectTableRow;
end 
end 

function handleNameChanged( this, dlg, value )

existingProfiles = this.allProfiles;
if ( this.isProfileSelectedInBrowser )
for i = 1:length( existingProfiles )
if existingProfiles( i ).getName == string( value )
dp = DAStudio.DialogProvider;
eDlg = dp.errordlg(  ...
DAStudio.message( 'SystemArchitecture:Profile:ProfileAlreadyExists', value ),  ...
DAStudio.message( 'SystemArchitecture:ProfileDesigner:ErrorLoadingProfile' ),  ...
true );
this.positionDialog( eDlg, dlg );
end 
end 

newSelectedNode = value;
else 
oldStereotypeName = this.CurrentTreeSource.getName;
newSelectedNode = strrep( this.CurrentTreeNode, oldStereotypeName, value );
end 
txn = this.beginTransaction( this.CurrentTreeSource );
this.CurrentTreeSource.setName( value );
txn.commit;
this.CurrentTreeNode = newSelectedNode;
dlg.refresh(  );
end 

function handlePropertySetTableChange( this, dlg, row, col, value )


propSet = this.getCurrentPropertySet;
props = propSet.properties.toArray;
changedProp = props( row + 1 );
changedPropName = changedProp.getName;
propIsDerived = changedProp.isDerived;
this.SelectTableRow = this.CurrentPropertyRow;

try 
switch col
case 0
txn = this.beginTransaction( propSet );
propSet.renameProperty( changedPropName, value );
txn.commit;
case 1
origIdx = changedProp.p_Index;
replacedProp = [  ];

types = this.getPropertyTypeEntries(  );
typeName = types{ value + 1 };

valueType = this.getValueTypes.getByKey( typeName );

if ( strcmp( typeName, 'enumeration' ) )
if ~isa( changedProp.type, 'systemcomposer.property.Enumeration' )

edlg = systemcomposer.internal.profile.internal.EnumerationPicker( this, dlg, origIdx, changedPropName );
DAStudio.Dialog( edlg );
end 
else 


txn = this.beginTransaction( propSet );
if isa( valueType, 'systemcomposer.property.StringType' )
if ~isa( changedProp.type, 'systemcomposer.property.StringType' )
propSet.removeProperty( changedPropName );
replacedProp = propSet.addProperty( changedPropName, typeName );
end 
elseif isa( valueType, 'systemcomposer.property.FloatType' )
if isa( changedProp.type, 'systemcomposer.property.FloatType' )
currentTypeName = changedProp.getBaseType;
if ~strcmp( currentTypeName, typeName )
txn = mf.zero.getModel( changedProp ).beginTransaction(  );
changedProp.setBaseType( typeName );
txn.commit;
end 
else 
propSet.removeProperty( changedPropName );
replacedProp = propSet.addProperty( changedPropName, typeName );
end 
elseif isa( valueType, 'systemcomposer.property.IntegerType' )
if isa( changedProp.type, 'systemcomposer.property.IntegerType' )
currentTypeName = changedProp.getBaseType;
if ~strcmp( currentTypeName, typeName )
txn = mf.zero.getModel( changedProp ).beginTransaction(  );
changedProp.setBaseType( typeName );
txn.commit;
end 
else 
propSet.removeProperty( changedPropName );
replacedProp = propSet.addProperty( changedPropName, typeName );
end 
elseif isa( valueType, 'systemcomposer.property.BooleanType' )
if ~isa( changedProp.type, 'systemcomposer.property.BooleanType' )
propSet.removeProperty( changedPropName );
replacedProp = propSet.addProperty( changedPropName, typeName );
end 
end 
txn.commit;
if ~isempty( replacedProp )

propSet.moveProperty( replacedProp.p_Index, origIdx );
end 

if ~isempty( replacedProp )
replacedProp.isDerived = propIsDerived;
end 

dlg.refresh(  );
end 
case 2
assert( isa( changedProp.type, 'systemcomposer.property.Enumeration' ) );
if ( systemcomposer.property.Enumeration.isValidEnumerationName( value ) )
txn = mf.zero.getModel( changedProp ).beginTransaction(  );
propSet.removeProperty( changedPropName );

propSet.addEnumProperty( changedPropName, value );
txn.commit;
end 
dlg.refresh(  );
case 3
txn = mf.zero.getModel( changedProp ).beginTransaction(  );
changedProp.setUnit( value );
txn.commit;
dlg.refresh(  );
case 4
if isa( changedProp.type, 'systemcomposer.property.Enumeration' )
value = changedProp.type.getLiteralsAsStrings{ value + 1 };
value = "'" + value + "'";
elseif isa( changedProp.type, 'systemcomposer.property.BooleanType' )
if value
value = 'true';
else 
value = 'false';
end 
end 
txn = mf.zero.getModel( changedProp ).beginTransaction(  );
changedProp.setDefaultPropertyValue( value );
txn.commit;
dlg.refresh(  );
end 
catch me
dlg.refresh(  );
throw( me );
end 
end 

function handleProfileDefaultArchitectureChange( this, dlg, selection )
src = this.CurrentTreeSource;
mdl = mf.zero.getModel( src );
txn = mdl.beginTransaction;
if isa( src, 'systemcomposer.internal.profile.Profile' )
list = this.getArchitecturePrototypes;
protos = src.prototypes.toArray;
src.defaultArchPrototype = systemcomposer.internal.profile.Prototype.empty;
for i = 1:numel( protos )
if strcmp( protos( i ).getName, list{ selection + 1 } )
src.setDefaultPrototype( protos( i ) );
break ;
end 
end 
end 
txn.commit;
dlg.refresh(  );
end 

function handlePrototypeDefaultArchitectureChange( this, dlg, selection )
src = this.CurrentTreeSource;
mdl = mf.zero.getModel( src );
txn = mdl.beginTransaction;
if isa( src, 'systemcomposer.internal.profile.Prototype' )
list = this.getArchitecturePrototypes;
protos = src.profile.prototypes.toArray;
src.defaultStereotypeMap.removeArchitectureDefault;
for i = 1:numel( protos )
if strcmp( protos( i ).getName, list{ selection + 1 } )
src.defaultStereotypeMap.setArchitectureDefault( protos( i ) );
break ;
end 
end 
end 
txn.commit;
dlg.refresh(  );
end 

function handlePrototypeDefaultPortChange( this, dlg, selection )
src = this.CurrentTreeSource;
mdl = mf.zero.getModel( src );
txn = mdl.beginTransaction;
if isa( src, 'systemcomposer.internal.profile.Prototype' )
list = this.getPortPrototypes;
protos = src.profile.prototypes.toArray;
src.defaultStereotypeMap.removePortDefault;
for i = 1:numel( protos )
if strcmp( protos( i ).getName, list{ selection + 1 } )
src.defaultStereotypeMap.setPortDefault( protos( i ) );
break ;
end 
end 
end 
txn.commit;
dlg.refresh(  );
end 

function handlePrototypeDefaultConnectorChange( this, dlg, selection )
src = this.CurrentTreeSource;
mdl = mf.zero.getModel( src );
txn = mdl.beginTransaction;
if isa( src, 'systemcomposer.internal.profile.Prototype' )
list = this.getConnectorPrototypes;
protos = src.profile.prototypes.toArray;
src.defaultStereotypeMap.removeConnectorDefault;
for i = 1:numel( protos )
if strcmp( protos( i ).getName, list{ selection + 1 } )
src.defaultStereotypeMap.setConnectorDefault( protos( i ) );
break ;
end 
end 
end 
txn.commit;
dlg.refresh(  );
end 

function handlePrototypeDefaultFunctionChange( this, ~, selection )
src = this.CurrentTreeSource;
mdl = mf.zero.getModel( src );
txn = mdl.beginTransaction;
if isa( src, 'systemcomposer.internal.profile.Prototype' )
list = this.getFunctionPrototypes;
protos = src.profile.prototypes.toArray;
src.defaultStereotypeMap.removeFunctionDefault;
for i = 1:numel( protos )
if strcmp( protos( i ).getName, list{ selection + 1 } )
src.defaultStereotypeMap.setFunctionDefault( protos( i ) );
break ;
end 
end 
end 
txn.commit;
end 

function setShowInheritedStereotypeProperties( this, value )



this.ShowInheritedStereotypeProperties = value;
end 

function node = createTreeNode( this, source, parent )
if nargin < 3
parent = [  ];
end 
source.id = systemcomposer.internal.profile.Designer.getID( source.fqn );
node = systemcomposer.internal.profile.internal.TreeNode( source, parent, this );
end 

function node = createStereotypeNode( this, parent )
assert( ~isempty( parent ) );
node = systemcomposer.internal.profile.internal.StereotypeTreeNode( parent, this );
end 

function node = createPropertySetNode( this, parent )
assert( ~isempty( parent ) );
node = systemcomposer.internal.profile.internal.PropertySetTreeNode( parent, this );
end 

function has = hasUnsavedProfiles( this )


has = false;
for idx = 1:length( this.ProfileModels )
m = this.ProfileModels( idx );
profile = systemcomposer.internal.profile.Profile.getProfile( m );
if profile.dirty
has = true;
return ;
end 
end 
end 

function has = hasUnsavedChanges( ~, profile )


has = profile.dirty;
end 

function profile = getCurrentProfile( this )


if this.isProfileSelectedInBrowser(  )
profile = this.CurrentTreeSource;
elseif this.isPrototypeSelectedInBrowser(  )
profile = this.CurrentTreeSource.profile;
elseif this.isPropertySetSelectedInBrowser(  )
profile = this.CurrentTreeSource.profile;
else 
profile = [  ];
end 
end 

function prototype = getCurrentPrototype( this )


if this.isPrototypeSelectedInBrowser(  )
prototype = this.CurrentTreeSource;
else 
prototype = [  ];
end 
end 

function b = isPrototypeType( ~, prototype, appliesToElem )
if isempty( prototype.appliesTo.toArray )
b = false;
else 
b = any( ismember( prototype.appliesTo.toArray, appliesToElem ) );
end 
if ~b
parent = prototype;
while ~b && ~isempty( parent )
parent = parent.parent;
if ~isempty( parent )
if ~isempty( parent.appliesTo.toArray )
b = ismember( parent.appliesTo.toArray, appliesToElem );
end 
end 
end 
end 
end 

end 

methods ( Access = protected )

function schema = getDescriptionSchema( this )


icon.Type = 'image';
icon.FilePath = this.resource( 'profileNode' );
icon.RowSpan = [ 1, 1 ];
icon.ColSpan = [ 1, 1 ];

title.Type = 'text';
title.Name = this.getDescTitle(  );
title.FontPointSize = 12;
title.Bold = true;
title.RowSpan = [ 1, 1 ];
title.ColSpan = [ 2, 2 ];

desc.Type = 'text';
desc.Tag = 'txtDesc';
desc.WordWrap = true;
desc.RowSpan = [ 2, 2 ];
desc.ColSpan = [ 1, 2 ];
desc.Name = this.getDescText(  );

expand.Type = 'hyperlink';
expand.Tag = 'descExpandLink';
expand.Source = this;
expand.ObjectMethod = 'handleDescExpandClick';
expand.MethodArgs = {  };
expand.ArgDataTypes = {  };
expand.Graphical = true;
expand.DialogRefresh = true;
expand.RowSpan = [ 2, 2 ];
expand.ColSpan = [ 3, 3 ];
expand.Alignment = 3;
if this.DescExpanded
expand.Name = DAStudio.message( 'SystemArchitecture:ProfileDesigner:Less' );
else 
expand.Name = DAStudio.message( 'SystemArchitecture:ProfileDesigner:More' );
end 

schema.Type = 'group';
schema.Name = '';
schema.Items = { icon, title, desc, expand };
schema.LayoutGrid = [ 2, 3 ];
schema.RowStretch = [ 0, 1 ];
schema.ColStretch = [ 0, 1, 0 ];
end 

function schema = getToolbarSchema( this )



toolbarCol = 1;


col = 0;

col = col + 1;
profileTxt.Type = 'text';
profileTxt.Tag = 'profileTxt';
profileTxt.WordWrap = true;
profileTxt.RowSpan = [ 1, 1 ];
profileTxt.ColSpan = [ col, col ];
profileTxt.Name = DAStudio.message( 'SystemArchitecture:ProfileDesigner:Profile' );

col = col + 1;
newProfile.Type = 'pushbutton';
newProfile.Tag = 'newProfileButton';
newProfile.Source = this;
newProfile.ObjectMethod = 'handleClickNewProfile';
newProfile.MethodArgs = {  };
newProfile.ArgDataTypes = {  };
newProfile.DialogRefresh = true;
newProfile.RowSpan = [ 1, 1 ];
newProfile.ColSpan = [ col, col ];
newProfile.Enabled = true;
newProfile.ToolTip = DAStudio.message( 'SystemArchitecture:ProfileDesigner:NewProfileTooltip' );
newProfile.FilePath = this.resource( 'newProfile' );
newProfile.Name = DAStudio.message( 'SystemArchitecture:ProfileDesigner:NewProfile' );

col = col + 1;
importProfile.Type = 'pushbutton';
importProfile.Tag = 'importProfile';
importProfile.Source = this;
importProfile.ObjectMethod = 'handleClickImportProfile';
importProfile.MethodArgs = { '%dialog' };
importProfile.ArgDataTypes = { 'handle' };
importProfile.DialogRefresh = true;
importProfile.RowSpan = [ 1, 1 ];
importProfile.ColSpan = [ col, col ];
importProfile.Enabled = true;
importProfile.ToolTip = DAStudio.message( 'SystemArchitecture:ProfileDesigner:ImportProfileTooltip' );
importProfile.FilePath = this.resource( 'importProfile' );
importProfile.Name = DAStudio.message( 'SystemArchitecture:ProfileDesigner:Open' );

col = col + 1;
exportProfile.Type = 'splitbutton';
exportProfile.Tag = 'exportProfile';
exportProfile.ActionEntries = {  ...
systemcomposer.internal.profile.internal.SaveButtonAction( this ),  ...
systemcomposer.internal.profile.internal.SaveAsButtonAction( this ),  ...
systemcomposer.internal.profile.internal.SaveAllButtonAction( this ),  ...
systemcomposer.internal.profile.internal.ExportToPreviousButtonAction( this ) };
exportProfile.DefaultAction = 'saveButtonAction';
exportProfile.ActionCallback = @( dlg, w, action )this.handleClickSaveProfile( dlg, w, action );
exportProfile.DialogRefresh = true;
exportProfile.RowSpan = [ 1, 1 ];
exportProfile.ColSpan = [ col, col ];
exportProfile.ToolTip = DAStudio.message( 'SystemArchitecture:ProfileDesigner:ExportProfileTooltip' );
exportProfile.FilePath = this.resource( 'exportProfile' );

col = col + 1;
closeButton.Type = 'pushbutton';
closeButton.Tag = 'closeProfileButton';
closeButton.Source = this;
closeButton.ObjectMethod = 'handleClickCloseProfile';
closeButton.MethodArgs = { '%dialog' };
closeButton.ArgDataTypes = { 'handle' };
closeButton.DialogRefresh = true;
closeButton.RowSpan = [ 1, 1 ];
closeButton.ColSpan = [ col, col ];
closeButton.Enabled = this.isProfileSelectedInBrowser(  );
closeButton.ToolTip = DAStudio.message( 'SystemArchitecture:ProfileDesigner:CloseProfileTooltip' );
closeButton.FilePath = this.resource( 'delete' );

profileGroup.Type = 'group';
profileGroup.Name = '';
profileGroup.Items = { profileTxt, newProfile, importProfile, exportProfile, closeButton };
profileGroup.LayoutGrid = [ 1, col ];
profileGroup.ColStretch = zeros( 1, col );
profileGroup.RowSpan = [ 1, 1 ];
profileGroup.ColSpan = [ toolbarCol, toolbarCol ];

toolbarCol = toolbarCol + 1;

col = 0;

col = col + 1;
stereotypeTxt.Type = 'text';
stereotypeTxt.Tag = 'prototypeTxt';
stereotypeTxt.WordWrap = true;
stereotypeTxt.RowSpan = [ 1, 1 ];
stereotypeTxt.ColSpan = [ col, col ];
stereotypeTxt.Name = DAStudio.message( 'SystemArchitecture:ProfileDesigner:Stereotype' );

col = col + 1;
newPrototype.Type = 'pushbutton';
newPrototype.Tag = 'newPrototype';
newPrototype.Source = this;
newPrototype.ObjectMethod = 'handleClickNewPrototype';
newPrototype.MethodArgs = {  };
newPrototype.ArgDataTypes = {  };
newPrototype.DialogRefresh = true;
newPrototype.RowSpan = [ 1, 1 ];
newPrototype.ColSpan = [ col, col ];
newPrototype.Enabled = this.isProfileSelectedInBrowser(  ) || this.isPrototypeSelectedInBrowser(  );
newPrototype.ToolTip = DAStudio.message( 'SystemArchitecture:ProfileDesigner:NewPrototypeTooltip' );
newPrototype.FilePath = this.resource( 'newPrototype' );
newPrototype.Name = DAStudio.message( 'SystemArchitecture:ProfileDesigner:NewStereotype' );

col = col + 1;
deleteButton.Type = 'pushbutton';
deleteButton.Tag = 'deletePrototypeButton';
deleteButton.Source = this;
deleteButton.ObjectMethod = 'handleClickDeletePrototype';
deleteButton.MethodArgs = { '%dialog' };
deleteButton.ArgDataTypes = { 'handle' };
deleteButton.DialogRefresh = true;
deleteButton.RowSpan = [ 1, 1 ];
deleteButton.ColSpan = [ col, col ];
deleteButton.Enabled = this.isProfileSelectedInBrowser(  ) || this.isPrototypeSelectedInBrowser(  );
deleteButton.ToolTip = DAStudio.message( 'SystemArchitecture:ProfileDesigner:DeleteTooltip' );
deleteButton.FilePath = this.resource( 'delete' );

prototypeGroup.Type = 'group';
prototypeGroup.Name = '';
prototypeGroup.Items = { stereotypeTxt, newPrototype, deleteButton };
prototypeGroup.LayoutGrid = [ 1, col ];
prototypeGroup.ColStretch = zeros( 1, col );
prototypeGroup.RowSpan = [ 1, 1 ];
prototypeGroup.ColSpan = [ toolbarCol, toolbarCol ];

toolbarCol = toolbarCol + 1;

if this.isFeatureEnabled( 'ZCPropertySets' )

col = 0;

col = col + 1;
propSetTxt.Type = 'text';
propSetTxt.Tag = 'propSetTxt';
propSetTxt.WordWrap = true;
propSetTxt.RowSpan = [ 1, 1 ];
propSetTxt.ColSpan = [ col, col ];
propSetTxt.Name = 'Property Set';

col = col + 1;
newPropSet.Type = 'pushbutton';
newPropSet.Tag = 'newPropSet';
newPropSet.Source = this;
newPropSet.ObjectMethod = 'handleClickNewPropertySet';
newPropSet.MethodArgs = {  };
newPropSet.ArgDataTypes = {  };
newPropSet.DialogRefresh = true;
newPropSet.RowSpan = [ 1, 1 ];
newPropSet.ColSpan = [ col, col ];
newPropSet.Enabled = this.isProfileSelectedInBrowser(  );
newPropSet.ToolTip = 'Create a new property set';
newPropSet.FilePath = this.resource( 'newPrototype' );
newPropSet.Name = 'New Property Set';

col = col + 1;
deleteButton.Type = 'pushbutton';
deleteButton.Tag = 'deletePropSetButton';
deleteButton.Source = this;
deleteButton.ObjectMethod = 'handleClickDeletePropSet';
deleteButton.MethodArgs = { '%dialog' };
deleteButton.ArgDataTypes = { 'handle' };
deleteButton.DialogRefresh = true;
deleteButton.RowSpan = [ 1, 1 ];
deleteButton.ColSpan = [ col, col ];
deleteButton.Enabled = this.isProfileSelectedInBrowser(  ) || this.isPropertySetSelectedInBrowser(  );
deleteButton.ToolTip = DAStudio.message( 'SystemArchitecture:ProfileDesigner:DeletePSTooltip' );
deleteButton.FilePath = this.resource( 'delete' );

propSetGroup.Type = 'group';
propSetGroup.Name = '';
propSetGroup.Items = { propSetTxt, newPropSet, deleteButton };
propSetGroup.LayoutGrid = [ 1, col ];
propSetGroup.ColStretch = zeros( 1, col );
propSetGroup.RowSpan = [ 1, 1 ];
propSetGroup.ColSpan = [ toolbarCol, toolbarCol ];

toolbarCol = toolbarCol + 1;
end 


col = 0;

col = col + 1;
modelTxt.Type = 'text';
modelTxt.Tag = 'modelTxt';
modelTxt.RowSpan = [ 1, 1 ];
modelTxt.ColSpan = [ col, col ];
modelTxt.Name = DAStudio.message( 'SystemArchitecture:ProfileDesigner:ImportIntoModelOrDD' );

col = col + 1;
importIntoModelOrDD.Type = 'splitbutton';
importIntoModelOrDD.Tag = 'importIntoModelOrDD';
importIntoModelOrDD.ActionCallback = @( dlg, w, action )this.handleClickImportProfileIntoModelorDD( dlg, w, action );
importIntoModelOrDD.DialogRefresh = true;
importIntoModelOrDD.RowSpan = [ 1, 1 ];
importIntoModelOrDD.ColSpan = [ col, col ];
importIntoModelOrDD.ToolTip = DAStudio.message( 'SystemArchitecture:ProfileDesigner:ImportIntoModelOrDDTooltip' );

mdls = this.getOpenArchitectureModelsAndDictionaries(  );
if ~isempty( mdls )
actionEntries = cell( 1, length( mdls ) + 1 );
actionEntries{ 1 } = systemcomposer.internal.profile.internal.ImportProfileToModelNOAction( 'select_action' );
for idx = 1:length( mdls )
mdl = mdls{ idx };
action = systemcomposer.internal.profile.internal.ImportProfileToModelAction( mdl );
actionEntries{ idx + 1 } = action;
end 
importIntoModelOrDD.ActionEntries = actionEntries;
importIntoModelOrDD.DefaultAction = actionEntries{ 1 }.getTag(  );
importIntoModelOrDD.Enabled = this.isProfileSelectedInBrowser(  ) || this.isPrototypeSelectedInBrowser(  );
else 

actionObj = systemcomposer.internal.profile.internal.ImportProfileToModelNOAction( 'none_action' );
importIntoModelOrDD.ActionEntries = { actionObj };
importIntoModelOrDD.DefaultAction = actionObj.getTag(  );
importIntoModelOrDD.Enabled = false;
end 

modelGroup.Type = 'group';
modelGroup.Items = { modelTxt, importIntoModelOrDD };
modelGroup.LayoutGrid = [ 1, col ];
modelGroup.ColStretch = zeros( 1, col );
modelGroup.RowSpan = [ 1, 1 ];
modelGroup.ColSpan = [ toolbarCol, toolbarCol ];

toolbarCol = toolbarCol + 2;


helpButton.Type = 'pushbutton';
helpButton.Tag = 'help';
helpButton.Source = this;
helpButton.ObjectMethod = 'handleClickHelp';
helpButton.MethodArgs = {  };
helpButton.ArgDataTypes = {  };
helpButton.RowSpan = [ 1, 1 ];
helpButton.ColSpan = [ 1, 1 ];
helpButton.Enabled = true;
helpButton.ToolTip = DAStudio.message( 'SystemArchitecture:ProfileDesigner:HelpTooltip' );
helpButton.FilePath = this.resource( 'help' );

helpGroup.Type = 'group';
helpGroup.Items = { helpButton };
helpGroup.RowSpan = [ 1, 1 ];
helpGroup.ColSpan = [ toolbarCol, toolbarCol ];

schema.Type = 'panel';
if this.isFeatureEnabled( 'ZCPropertySets' )
schema.Items = { profileGroup, prototypeGroup, propSetGroup, modelGroup, helpGroup };
else 
schema.Items = { profileGroup, prototypeGroup, modelGroup, helpGroup };
end 
schema.LayoutGrid = [ 1, toolbarCol ];
schema.ColStretch = [ zeros( 1, toolbarCol - 2 ), 1, 0 ];

end 

function schema = getProfileBrowserSchema( this )



filter.Type = 'combobox';
filter.Tag = 'profileFilterCombo';
filter.Name = DAStudio.message( 'SystemArchitecture:ProfileDesigner:FilterProfiles' );
filter.NameLocation = 1;
filter.Entries = this.getProfileFilterList(  );
filter.Value = this.ProfileFilter;
filter.Source = this;
filter.ObjectMethod = 'handleProfileFilterChanged';
filter.MethodArgs = { '%dialog', '%value' };
filter.ArgDataTypes = { 'handle', 'char' };
filter.Mode = true;
filter.DialogRefresh = true;
filter.RowSpan = [ 1, 1 ];
filter.ColSpan = [ 1, 1 ];
filter.ToolTip = DAStudio.message( 'SystemArchitecture:ProfileDesigner:FilterProfilesTooltip' );



[ profiles, hasMore ] = this.getProfilesInFilter(  );
if isempty( profiles )
if hasMore

model{ 1 } = systemcomposer.internal.profile.internal.AllFilteredTreeNode(  );
else 

model{ 1 } = systemcomposer.internal.profile.internal.NullTreeNode(  );
end 
else 
model = cell( 1, length( profiles ) );
for idx = 1:length( profiles )
source.obj = profiles( idx );
source.id = systemcomposer.internal.profile.Designer.getID( source.obj.getName );
node = systemcomposer.internal.profile.internal.TreeNode( source, [  ], this );
model{ 1, idx } = node;
end 
end 

profileBrowser.Type = 'tree';
profileBrowser.Name = '';
profileBrowser.Tag = 'profileBrowserTree';
profileBrowser.TreeModel = model;
profileBrowser.TreeMultiSelect = false;
profileBrowser.ExpandTree = true;
profileBrowser.Source = this;
profileBrowser.ObjectMethod = 'handleClickProfileBrowserNode';
profileBrowser.MethodArgs = { '%dialog', '%value' };
profileBrowser.ArgDataTypes = { 'handle', 'mxArray' };
profileBrowser.DialogRefresh = true;
profileBrowser.Graphical = true;
profileBrowser.RowSpan = [ 2, 2 ];
profileBrowser.ColSpan = [ 1, 1 ];

schema.Type = 'group';
schema.Name = DAStudio.message( 'SystemArchitecture:ProfileDesigner:ProfileBrowser' );
schema.Items = { filter, profileBrowser };
schema.LayoutGrid = [ 2, 1 ];
schema.RowStretch = [ 0, 1 ];

end 

function schema = getSelectedItemPropertiesSchema( this )


if this.isProfileSelectedInBrowser(  )
schema = this.getProfilePropertiesSchema(  );

elseif this.isPrototypeSelectedInBrowser(  )
schema = this.getPrototypePropertiesSchema(  );

elseif this.isPropertySetSelectedInBrowser(  )
schema = this.getPropertySetInProfileSchema(  );

else 

schema = this.getEmptyPanelSchema(  );
end 

end 

function schema = getEmptyPanelSchema( ~ )

schema.Type = 'group';
schema.Name = DAStudio.message( 'SystemArchitecture:ProfileDesigner:NothingSelected' );
schema.Items = {  };
schema.LayoutGrid = [ 1, 1 ];

end 

function schema = getProfilePropertiesSchema( this )


row = 0;
items = {  };

profile = this.CurrentTreeSource;
if profile.isUnhealthyOnLoad
ex = MException( message( 'SystemArchitecture:Profile:ErrorLoadingProfile', profile.getName(  ) ) );
causeMsg = profile.healthCheckErrorOnLoad;
cause = MException( 'SystemArchitecture:Profile:ErrorLoadingProfileCause', causeMsg );
ex = ex.addCause( cause );

row = row + 1;
err.Type = 'text';
err.Tag = 'profileLoadErrorText';
err.Name = ex.getReport(  );
err.WordWrap = true;
err.RowSpan = [ row, row ];
err.ForegroundColor = [ 255, 0, 0 ];
err.ColSpan = [ 1, 1 ];
items = [ items, { err } ];

checkLink.Type = 'hyperlink';
checkLink.Tag = 'profileLoadErrorLink';
checkLink.Name = 'Check profile';
checkLink.Source = this;
checkLink.ObjectMethod = 'checkProfileHealth';
checkLink.MethodArgs = {  };
checkLink.ArgDataTypes = {  };
checkLink.Graphical = true;
checkLink.DialogRefresh = true;
checkLink.RowSpan = [ row, row ];
checkLink.ColSpan = [ 2, 2 ];
items = [ items, { checkLink } ];
end 

row = row + 1;
name.Type = 'edit';
name.Tag = 'profileName';
name.Name = DAStudio.message( 'SystemArchitecture:ProfileDesigner:Name' );
name.NameLocation = 1;
name.Source = this;
name.Value = this.CurrentTreeSource.getName(  );
name.ObjectMethod = 'handleNameChanged';
name.MethodArgs = { '%dialog', '%value' };
name.ArgDataTypes = { 'handle', 'char' };
name.Graphical = true;
name.Mode = true;
name.DialogRefresh = true;
name.RowSpan = [ row, row ];
name.ColSpan = [ 1, 2 ];
name.ToolTip = DAStudio.message( 'SystemArchitecture:ProfileDesigner:ProfileNameTooltip' );
items = [ items, { name } ];

row = row + 1;
friendlyName.Type = 'edit';
friendlyName.Tag = 'profileFriendlyName';
friendlyName.Name = DAStudio.message( 'SystemArchitecture:ProfileDesigner:FriendlyName' );
friendlyName.NameLocation = 2;
friendlyName.Source = this.CurrentTreeSource;
friendlyName.ObjectProperty = 'friendlyName';
friendlyName.Graphical = true;
friendlyName.Mode = true;
friendlyName.DialogRefresh = true;
friendlyName.RowSpan = [ row, row ];
friendlyName.ColSpan = [ 1, 2 ];
friendlyName.ToolTip = DAStudio.message( 'SystemArchitecture:ProfileDesigner:ProfileFriendlyNameTooltip' );
items = [ items, { friendlyName } ];

row = row + 1;
archProto.Type = 'combobox';
archProto.Tag = 'profDefaultComponent';
archProto.Name = DAStudio.message( 'SystemArchitecture:ProfileDesigner:ProfileDefaultName' );
archProto.NameLocation = 1;
[ e, val ] = this.getArchitecturePrototypes;
archProto.Entries = e;
archProto.Value = val;
archProto.Source = this;
archProto.ObjectMethod = 'handleProfileDefaultArchitectureChange';
archProto.MethodArgs = { '%dialog', '%value' };
archProto.ArgDataTypes = { 'handle', 'char' };
archProto.Mode = true;
archProto.DialogRefresh = true;
archProto.RowSpan = [ row, row ];
archProto.ColSpan = [ 1, 1 ];
archProto.ToolTip = DAStudio.message( 'SystemArchitecture:ProfileDesigner:ProfileDefaultNameTooltip' );
items = [ items, { archProto } ];

row = row + 1;
desc.Type = 'editarea';
desc.Tag = 'profileDesc';
desc.Name = DAStudio.message( 'SystemArchitecture:ProfileDesigner:Description' );
desc.NameLocation = 2;
desc.Source = this.CurrentTreeSource;
desc.ObjectProperty = 'description';
desc.Graphical = true;
desc.Mode = true;
desc.DialogRefresh = true;
desc.RowSpan = [ row, row ];
desc.ColSpan = [ 1, 2 ];
desc.ToolTip = DAStudio.message( 'SystemArchitecture:ProfileDesigner:ProfileDescriptionTooltip' );
items = [ items, { desc } ];

schema.Type = 'group';
schema.Name = DAStudio.message( 'SystemArchitecture:ProfileDesigner:ProfileProperties' );
schema.Items = items;
schema.LayoutGrid = [ row, 2 ];
schema.RowStretch = [ zeros( 1, row - 1 ), 1 ];
schema.ColStretch = [ 1, 0 ];
end 

function schema = getPrototypePropertiesSchema( this )

assert( isa( this.CurrentTreeSource, 'systemcomposer.internal.profile.Prototype' ) );


name.Type = 'edit';
name.Tag = 'prototypeName';
name.Name = DAStudio.message( 'SystemArchitecture:ProfileDesigner:Name' );
name.NameLocation = 1;
name.Source = this;
name.Value = this.CurrentTreeSource.getName(  );
name.ObjectMethod = 'handleNameChanged';
name.MethodArgs = { '%dialog', '%value' };
name.ArgDataTypes = { 'handle', 'char' };
name.Graphical = true;
name.Mode = true;
name.DialogRefresh = true;
name.ToolTip = DAStudio.message( 'SystemArchitecture:ProfileDesigner:PrototypeNameTooltip' );

nameGroup.Type = 'panel';
nameGroup.Name = '';
nameGroup.Items = { name };


swTreeItems = {  };
if this.isFeatureEnabled( 'SoftwareModeling' )
swTreeItems{ end  + 1 } = 'Function';
swTreeItems{ end  + 1 } = 'Task';
end 
if this.isFeatureEnabled( 'ZCEventChainAdvanced' )
swTreeItems{ end  + 1 } = 'EventChain';
end 

appliesTo = this.CurrentTreeSource.appliesTo.toArray;
if isempty( appliesTo )
appliesTo = getString( message( 'SystemArchitecture:ProfileDesigner:All' ) );
else 
appliesTo = appliesTo{ 1 };
end 

if this.isFeatureEnabled( 'SoftwareModeling' ) ||  ...
this.isFeatureEnabled( 'ZCEventChainAdvanced' )
elementTree.Type = 'tree';
elementTree.Tag = 'prototypeExtendsTree';
elementTree.Name = '';
elementTree.NameLocation = 1;
elementTree.TreeItems = this.getMetaclassEntries(  );

if this.ShowSoftwareElements
elementTree.TreeItems = [ elementTree.TreeItems,  ...
swTreeItems,  ...
getString( message( 'SystemArchitecture:ProfileDesigner:ShowLess' ) ) ];
else 
elementTree.TreeItems = [ elementTree.TreeItems ...
, getString( message( 'SystemArchitecture:ProfileDesigner:ShowMore' ) ) ];
end 

elementTree.Source = this;
elementTree.ObjectMethod = 'handlePrototypeTreeAppliesToChange';
elementTree.MethodArgs = { '%dialog', '%value' };
elementTree.ArgDataTypes = { 'handle', 'char' };
elementTree.Mode = true;
elementTree.DialogRefresh = true;

extends.Type = 'togglepanel';
extends.Name = [ getString( message( 'SystemArchitecture:ProfileDesigner:AppliesTo' ) ), ' ', appliesTo ];
extends.Tag = 'AppliesToTogglePanel';
extends.Expand = false;
extends.Items = { elementTree };
else 
extends.Type = 'combobox';
extends.Tag = 'prototypeExtendsCombo';
extends.Name = DAStudio.message( 'SystemArchitecture:ProfileDesigner:AppliesTo' );
extends.NameLocation = 1;
extends.Entries = this.getMetaclassEntries(  );
extends.Value = this.getPrototypeExtendsValue(  );
extends.Source = this;
extends.ObjectMethod = 'handlePrototypeAppliesToChange';
extends.MethodArgs = { '%dialog', '%value' };
extends.ArgDataTypes = { 'handle', 'char' };
extends.Mode = true;
extends.DialogRefresh = true;
if isempty( this.CurrentTreeSource.parent ) ||  ...
( ~isempty( this.CurrentTreeSource.parent ) &&  ...
isempty( this.CurrentTreeSource.parent.getExtendedElement ) )


extends.Enabled = true;
extends.UserData = 1;
else 
extends.Enabled = false;
extends.UserData = 0;
end 
end 

extends.ToolTip = DAStudio.message( 'SystemArchitecture:ProfileDesigner:PrototypeAppliesToTooltip' );



extendsFunctionDesc.Type = 'text';
extendsFunctionDesc.ForegroundColor = [ 128, 128, 128 ];
extendsFunctionDesc.Name = message( 'SystemArchitecture:ProfileDesigner:AppliesToFunctionDescription' ).string;
extendsFunctionDesc.Tag = 'extendsFunctionDesc';
extendsFunctionDesc.Alignment = 6;


compIcon.Type = 'pushbutton';
compIcon.Tag = 'prototypeIconPickerButton';
compIcon.Name = DAStudio.message( 'SystemArchitecture:ProfileDesigner:Icon' );
compIcon.Source = this;
compIcon.ObjectMethod = 'handlePrototypeIconPickerClick';
compIcon.MethodArgs = { '%dialog' };
compIcon.ArgDataTypes = { 'handle' };
iconPath = this.getCurrentPrototypeIcon(  );
if isempty( iconPath )
prototype = this.CurrentTreeSource;
if ~isempty( prototype.icon )
iconPath = systemcomposer.internal.profile.internal.PrototypeIconPicker.getInvalidIconPath( prototype.getExtendedElement );
else 


compIcon.Name = DAStudio.message( 'SystemArchitecture:ProfileDesigner:NoIcon' );
end 
end 
compIcon.FilePath = iconPath;
compIcon.Enabled = this.currentPrototypeAppliesToComponentOrArchitecture;
compIcon.Mode = true;
compIcon.DialogRefresh = false;
compIcon.ToolTip = DAStudio.message( 'SystemArchitecture:ProfileDesigner:PrototypeIconTooltip' );


compColor.Type = 'pushbutton';
compColor.Tag = 'prototypeColorPickerButton';
compColor.FilePath = fullfile( matlabroot, 'toolbox', 'simulink', 'ui',  ...
'studio', 'config', 'icons', 'color_picker_16.png' );
compColor.Source = this;
compColor.ObjectMethod = 'handleCompPrototypeColorPickerClick';
compColor.MethodArgs = { '%dialog' };
compColor.ArgDataTypes = { 'handle' };
compColor.Enabled = this.currentPrototypeAppliesToComponent;
compColor.Mode = true;
compColor.DialogRefresh = false;
compColor.RowSpan = [ 1, 1 ];
compColor.ColSpan = [ 2, 2 ];
compColor.BackgroundColor = double( this.getPaletteColorFromComponentHeaderColor );
compColor.ToolTip = DAStudio.message( 'SystemArchitecture:ProfileDesigner:PrototypeColorTooltip' );

compStylingGroup.Type = 'panel';
compStylingGroup.Name = '';
compStylingGroup.Items = { compIcon, compColor };
compStylingGroup.LayoutGrid = [ 1, 2 ];
compStylingGroup.Alignment = 1;


portIcon.Type = 'pushbutton';
portIcon.Tag = 'prototypeIconPickerButton';
portIcon.Name = DAStudio.message( 'SystemArchitecture:ProfileDesigner:Icon' );
portIcon.Source = this;
portIcon.ObjectMethod = 'handlePrototypeIconPickerClick';
portIcon.MethodArgs = { '%dialog' };
portIcon.ArgDataTypes = { 'handle' };
portIcon.FilePath = this.getCurrentPrototypeIcon(  );
portIcon.Enabled = this.isFeatureEnabled( 'PortStereotypeIcons' ) && this.currentPrototypeAppliesToPort;
portIcon.Mode = true;
portIcon.DialogRefresh = false;
portIcon.ToolTip = DAStudio.message( 'SystemArchitecture:ProfileDesigner:PrototypeIconTooltip' );



extendsGroupItems = { extends };
extendsMaxCol = 1;
if this.isPrototypeType( this.CurrentTreeSource, 'Function' ) ...
 && ~this.isFeatureEnabled( 'SoftwareModeling' )
extendsMaxCol = 3;
extendsGroupItems = [ extendsGroupItems, { extendsFunctionDesc } ];
elseif this.isPrototypeType( this.CurrentTreeSource, 'Component' )
extendsMaxCol = 3;
extendsGroupItems = [ extendsGroupItems, { compStylingGroup } ];
elseif this.isPrototypeType( this.CurrentTreeSource, 'Port' ) ...
 && this.isFeatureEnabled( 'PortStereotypeIcons' )
extendsMaxCol = 2;
extendsGroupItems = [ extendsGroupItems, { portIcon } ];
end 

extendsGroup.LayoutGrid = [ 1, extendsMaxCol ];
extendsGroup.ColStretch = [ 1, zeros( 1, extendsMaxCol - 1 ) ];
extendsGroup.Type = 'panel';
extendsGroup.Items = extendsGroupItems;


lineStyleTxt.Type = 'text';
lineStyleTxt.Tag = 'connectorLineStyleTxt';
lineStyleTxt.WordWrap = true;
lineStyleTxt.Name = DAStudio.message( 'SystemArchitecture:ProfileDesigner:ConnectorStyle' );
lineStyleTxt.Enabled = this.currentPrototypeAppliesToPort || this.currentPrototypeAppliesToInterface ...
 || this.currentPrototypeAppliesToConnector;

lineStyle.Type = 'pushbutton';
lineStyle.Tag = 'prototypeLineStylePickerButton';
lineStyle.Name = '';
lineStyle.Source = this;
lineStyle.ObjectMethod = 'handlePrototypeLineStylePickerClick';
lineStyle.MethodArgs = { '%dialog' };
lineStyle.ArgDataTypes = { 'handle' };
lineStyle.FilePath = this.getCurrentPrototypeLineStyleFilePath;
lineStyle.Enabled = this.currentPrototypeAppliesToPort || this.currentPrototypeAppliesToInterface ...
 || this.currentPrototypeAppliesToConnector;
lineStyle.Mode = true;
lineStyle.DialogRefresh = false;
lineStyle.ToolTip = DAStudio.message( 'SystemArchitecture:ProfileDesigner:PrototypeLineStyleTooltip' );

lineColor.Type = 'pushbutton';
lineColor.Tag = 'prototypeLineColorPickerButton';
lineColor.FilePath = fullfile( matlabroot, 'toolbox', 'simulink', 'ui',  ...
'studio', 'config', 'icons', 'color_picker_16.png' );
lineColor.Name = '';
lineColor.Source = this;
lineColor.ObjectMethod = 'handlePrototypeLineColorPickerClick';
lineColor.MethodArgs = { '%dialog' };
lineColor.ArgDataTypes = { 'handle' };
lineColor.Enabled = this.currentPrototypeAppliesToPort || this.currentPrototypeAppliesToInterface ...
 || this.currentPrototypeAppliesToConnector;
lineColor.Mode = true;
lineColor.DialogRefresh = false;
lineColor.BackgroundColor = double( this.getPaletteColorFromLineColor );
lineColor.ToolTip = DAStudio.message( 'SystemArchitecture:ProfileDesigner:PrototypeColorTooltip' );

connStyleGroup.Type = 'panel';
connStyleGroup.Name = '';
connStyleGroup.Items = { lineStyleTxt, lineStyle, lineColor };
connStyleGroup.LayoutGrid = [ 1, 3 ];
connStyleGroup.ColStretch = [ 0, 0, 0 ];
connStyleGroup.Alignment = 1;


base.Type = 'combobox';
base.Tag = 'prototypeBaseCombo';
base.Name = DAStudio.message( 'SystemArchitecture:ProfileDesigner:BaseStereotype' );
base.NameLocation = 1;
base.Entries = this.getBasePrototypeEntries(  );
base.Value = this.getPrototypeBaseValue(  );
base.Source = this;
base.ObjectMethod = 'handlePrototypeBaseChange';
base.MethodArgs = { '%dialog', '%value' };
base.ArgDataTypes = { 'handle', 'char' };
base.Mode = true;
base.DialogRefresh = true;
base.ToolTip = DAStudio.message( 'SystemArchitecture:ProfileDesigner:PrototypeBaseTooltip' );

baseGroup.Type = 'panel';
baseGroup.Name = '';
baseGroup.Items = { base };


abstract.Type = 'checkbox';
abstract.Tag = 'stereotypeAbstractCheckbox';
abstract.Name = DAStudio.message( 'SystemArchitecture:ProfileDesigner:IsAbstractStereotype' );
abstract.Value = this.CurrentTreeSource.abstract;
abstract.Source = this;
abstract.ObjectMethod = 'handleStereotypeAbstractChange';
abstract.MethodArgs = { '%dialog', '%value' };
abstract.ArgDataTypes = { 'handle', 'mxArray' };
abstract.Mode = true;
abstract.DialogRefresh = true;
abstract.ToolTip = DAStudio.message( 'SystemArchitecture:ProfileDesigner:PrototypeAbstractTooltip' );

abstractGroup.Type = 'panel';
abstractGroup.Name = '';
abstractGroup.Items = { abstract };
abstractGroup.LayoutGrid = [ 2, 2 ];
abstractGroup.RowStretch = [ 1, 2 ];
abstractGroup.ColStretch = [ 1, 1 ];


desc.Type = 'editarea';
desc.Tag = 'prototypeDesc';
desc.Name = DAStudio.message( 'SystemArchitecture:ProfileDesigner:Description' );
desc.NameLocation = 0;
desc.Source = this.CurrentTreeSource;
desc.ObjectProperty = 'description';
desc.Graphical = true;
desc.Mode = true;
desc.DialogRefresh = true;
desc.ToolTip = DAStudio.message( 'SystemArchitecture:ProfileDesigner:PrototypeDescTooltip' );
desc.PreferredSize = [ 5, 10 ];
desc.WordWrap = true;

descGroup.Type = 'panel';
descGroup.Name = '';
descGroup.Items = { desc };


isArchPrototype = isPrototypeType( this, this.CurrentTreeSource, 'Component' );
filler.Type = 'text';
filler.Name = '';

defArch.Type = 'combobox';
defArch.Tag = 'protoDefaultComponent';
defArch.Name = DAStudio.message( 'SystemArchitecture:ProfileDesigner:ComponentDefault' );
defArch.NameLocation = 1;
[ e, v ] = this.getArchitecturePrototypes(  );
defArch.Entries = e;
if isempty( v )
defArch.Value = DAStudio.message( 'SystemArchitecture:ProfileDesigner:none' );
else 
defArch.Value = v;
end 
defArch.Source = this;
defArch.ObjectMethod = 'handlePrototypeDefaultArchitectureChange';
defArch.MethodArgs = { '%dialog', '%value' };
defArch.ArgDataTypes = { 'handle', 'char' };
defArch.Mode = true;
defArch.DialogRefresh = true;
defArch.ToolTip = DAStudio.message( 'SystemArchitecture:ProfileDesigner:ComponentDefaultTooltip', this.CurrentTreeSource.getName );

defPort.Type = 'combobox';
defPort.Tag = 'protoDefaultPort';
defPort.Name = DAStudio.message( 'SystemArchitecture:ProfileDesigner:PortDefault' );
defPort.NameLocation = 1;
[ e, v ] = this.getPortPrototypes(  );
defPort.Entries = e;
if isempty( v )
defPort.Value = DAStudio.message( 'SystemArchitecture:ProfileDesigner:none' );
else 
defPort.Value = v;
end 
defPort.Source = this;
defPort.ObjectMethod = 'handlePrototypeDefaultPortChange';
defPort.MethodArgs = { '%dialog', '%value' };
defPort.ArgDataTypes = { 'handle', 'char' };
defPort.Mode = true;
defPort.DialogRefresh = true;
defPort.ToolTip = DAStudio.message( 'SystemArchitecture:ProfileDesigner:PortDefaultTooltip', this.CurrentTreeSource.getName );

defConn.Type = 'combobox';
defConn.Tag = 'protoDefaultConnector';
defConn.Name = DAStudio.message( 'SystemArchitecture:ProfileDesigner:ConnectorDefault' );
defConn.NameLocation = 1;
[ e, v ] = this.getConnectorPrototypes(  );
defConn.Entries = e;
if isempty( v )
defConn.Value = DAStudio.message( 'SystemArchitecture:ProfileDesigner:none' );
else 
defConn.Value = v;
end 
defConn.Source = this;
defConn.ObjectMethod = 'handlePrototypeDefaultConnectorChange';
defConn.MethodArgs = { '%dialog', '%value' };
defConn.ArgDataTypes = { 'handle', 'char' };
defConn.Mode = true;
defConn.DialogRefresh = true;
defConn.ToolTip = DAStudio.message( 'SystemArchitecture:ProfileDesigner:ConnectorDefaultTooltip', this.CurrentTreeSource.getName );

defFunction.Type = 'combobox';
defFunction.Tag = 'protoDefaultFunction';
defFunction.Name = DAStudio.message( 'SystemArchitecture:ProfileDesigner:DefaultFunctionStereotype' );
defFunction.NameLocation = 1;
[ e, v ] = this.getFunctionPrototypes(  );
defFunction.Entries = e;
if isempty( v )
defFunction.Value = DAStudio.message( 'SystemArchitecture:ProfileDesigner:none' );
else 
defFunction.Value = v;
end 
defFunction.Source = this;
defFunction.ObjectMethod = 'handlePrototypeDefaultFunctionChange';
defFunction.MethodArgs = { '%dialog', '%value' };
defFunction.ArgDataTypes = { 'handle', 'char' };
defFunction.Mode = true;
defFunction.DialogRefresh = true;
defFunction.ToolTip = DAStudio.message( 'SystemArchitecture:ProfileDesigner:DefaultFunctionStereotypeTooltip', this.CurrentTreeSource.getName );

defaultPanel.Type = 'togglepanel';
defaultPanel.Name = DAStudio.message( 'SystemArchitecture:ProfileDesigner:CompositionDefaultName' );
defaultPanel.Tag = 'stereotype_defaults_panel';
defaultPanel.Enabled = isArchPrototype;

defaultPanelItems = { filler, defArch, defPort, defConn, defFunction };
defaultPanel.Items = defaultPanelItems;

defaultGroup.Type = 'group';
defaultGroup.Name = '';
defaultGroup.Items = { defaultPanel };

propSchema = this.getPropertySetSchema(  );


propertyGroup.Type = 'group';
if this.isPrototypeType( this.CurrentTreeSource, 'Component' )
propertyGroup.Items = { nameGroup, extendsGroup, baseGroup, abstractGroup, defaultGroup };
propertyGroup.LayoutGrid = [ numel( propertyGroup.Items ), 1 ];
propertyGroup.RowStretch = [ zeros( 1, numel( propertyGroup.Items ) - 1 ), 1 ];
elseif this.isPrototypeType( this.CurrentTreeSource, 'Port' ) && this.isFeatureEnabled( 'PortStereotypeIcons' )
propertyGroup.Items = { nameGroup, extendsGroup, connStyleGroup, baseGroup, abstractGroup };
elseif this.isPrototypeType( this.CurrentTreeSource, 'Port' ) || this.isPrototypeType( this.CurrentTreeSource, 'Interface' ) ...
 || this.isPrototypeType( this.CurrentTreeSource, 'Connector' )
propertyGroup.Items = { nameGroup, extendsGroup, connStyleGroup, baseGroup, abstractGroup };
elseif this.isPrototypeType( this.CurrentTreeSource, 'Requirement' ) || this.isPrototypeType( this.CurrentTreeSource, 'Link' )
appliesToType = 'Link';
if this.isPrototypeType( this.CurrentTreeSource, 'Requirement' )
appliesToType = 'Requirement';
end 
metaTypeTable = this.metaConfig.getAppliesToPropSchema( appliesToType, this.CurrentTreeSource );
propertyGroup.Items = { nameGroup, extendsGroup, metaTypeTable, baseGroup, abstractGroup };
else 
propertyGroup.Items = { nameGroup, extendsGroup, baseGroup, abstractGroup };
end 
propertyGroup.Name = DAStudio.message( 'SystemArchitecture:ProfileDesigner:StereotypeProperties' );

propertyGroup.RowSpan = [ 1, 3 ];
propertyGroup.ColSpan = [ 1, 2 ];
descGroup.RowSpan = [ 1, 3 ];
descGroup.ColSpan = [ 3, 4 ];
propSchema.RowSpan = [ 4, 6 ];
propSchema.ColSpan = [ 1, 4 ];

schema.Type = 'group';
schema.Name = DAStudio.message( 'SystemArchitecture:ProfileDesigner:StereotypeProperties' );
schema.LayoutGrid = [ 6, 4 ];
schema.Items = { propertyGroup, descGroup, propSchema };
end 

function schema = getPropertySetInProfileSchema( this )


row = 1;
name.Type = 'edit';
name.Tag = 'propSetName';
name.Name = DAStudio.message( 'SystemArchitecture:ProfileDesigner:Name' );
name.NameLocation = 1;
name.Source = this;
name.Value = this.CurrentTreeSource.getName(  );
name.ObjectMethod = 'handleNameChanged';
name.MethodArgs = { '%dialog', '%value' };
name.ArgDataTypes = { 'handle', 'char' };
name.Graphical = true;
name.Mode = true;
name.DialogRefresh = true;
name.RowSpan = [ row, row ];
name.ColSpan = [ 1, 1 ];
name.ToolTip = 'Name of the selected Property Set';


row = row + 1;
desc.Type = 'edit';
desc.Tag = 'propSetDesc';
desc.Name = DAStudio.message( 'SystemArchitecture:ProfileDesigner:Description' );
desc.NameLocation = 1;
desc.Source = this.CurrentTreeSource;
desc.ObjectProperty = 'description';
desc.Graphical = true;
desc.Mode = true;
desc.DialogRefresh = true;
desc.RowSpan = [ row, row ];
desc.ColSpan = [ 1, 1 ];
desc.ToolTip = DAStudio.message( 'SystemArchitecture:ProfileDesigner:PropertySetDescTooltip' );

row = row + 1;
propSetSchema = getPropertySetSchema( this );
propSetSchema.RowSpan = [ row, row ];
propSetSchema.ColSpan = [ 1, 1 ];

schema.Type = 'group';
schema.Name = DAStudio.message( 'SystemArchitecture:ProfileDesigner:PropertySetGroupTitle' );
schema.LayoutGrid = [ row, 1 ];
schema.RowStretch = [ zeros( 1, row - 1 ), 1 ];
schema.Items = { name, desc, propSetSchema };
end 

function schema = getPropertySetSchema( this )


tableData = this.getCurrentPrototypePropertyTableData(  );

row = 2;
propTable.Type = 'table';
propTable.Tag = 'propTable';
propTable.Grid = true;
propTable.SelectionBehavior = 'row';
propTable.HeaderVisibility = [ 1, 1 ];
propTable.ColumnHeaderHeight = 2;
propTable.RowHeaderWidth = 2;
propTable.ColHeader = {  ...
DAStudio.message( 'SystemArchitecture:ProfileDesigner:PropertyNameCol' ),  ...
DAStudio.message( 'SystemArchitecture:ProfileDesigner:TypeCol' ),  ...
DAStudio.message( 'SystemArchitecture:ProfileDesigner:NameCol' ),  ...
DAStudio.message( 'SystemArchitecture:ProfileDesigner:UnitCol' ),  ...
DAStudio.message( 'SystemArchitecture:ProfileDesigner:DefaultCol' ) ...
 };
propTable.MinimumSize = [ 700, 250 ];
propTable.Size = size( tableData );
propTable.Data = tableData;
propTable.ColumnStretchable = [ 1, 1, 1, 1, 1 ];
propTable.Enabled = true;
propTable.Editable = true;
propTable.Graphical = true;
propTable.SelectionChangedCallback = @( dlg, tag )this.handleSelectPropertyInTable( dlg, tag );
propTable.ValueChangedCallback = @( dlg, row, col, val )this.handlePropertySetTableChange( dlg, row, col, val );
propTable.RowSpan = [ row, row ];
propTable.ColSpan = [ 1, 5 ];

if this.SelectTableRow >= 0
propTable.SelectedRow = double( this.SelectTableRow );
this.CurrentPropertyRow = this.SelectTableRow;
this.SelectTableRow =  - 1;
end 

addProp.Type = 'pushbutton';
addProp.Tag = 'addProp';
addProp.Source = this;
addProp.ObjectMethod = 'handleClickAddProperty';
addProp.MethodArgs = {  };
addProp.ArgDataTypes = {  };
addProp.DialogRefresh = true;
addProp.RowSpan = [ 1, 1 ];
addProp.ColSpan = [ 1, 1 ];
addProp.Enabled = true;
addProp.ToolTip = DAStudio.message( 'SystemArchitecture:ProfileDesigner:AddPropertyTooltip' );
addProp.FilePath = this.resource( 'addProperty' );

deleteProp.Type = 'pushbutton';
deleteProp.Tag = 'deleteProp';
deleteProp.Source = this;
deleteProp.ObjectMethod = 'handleClickDeleteProperty';
deleteProp.MethodArgs = {  };
deleteProp.ArgDataTypes = {  };
deleteProp.DialogRefresh = true;
deleteProp.RowSpan = [ 1, 1 ];
deleteProp.ColSpan = [ 2, 2 ];
deleteProp.Enabled = isfield( propTable, 'SelectedRow' );
deleteProp.ToolTip = DAStudio.message( 'SystemArchitecture:ProfileDesigner:DeletePropertyTooltip' );
deleteProp.FilePath = this.resource( 'deleteProperty' );

currentProp = this.getCurrentPropertyDefinitionInTable(  );

moveUp.Type = 'pushbutton';
moveUp.Tag = 'moveUp';
moveUp.Source = this;
moveUp.ObjectMethod = 'handleClickMovePropertyUp';
moveUp.DialogRefresh = true;
moveUp.RowSpan = [ 1, 1 ];
moveUp.ColSpan = [ 3, 3 ];
moveUp.Enabled = ~this.isFirstPropertyInTable( currentProp );
moveUp.ToolTip = DAStudio.message( 'SystemArchitecture:ProfileDesigner:MoveUpPropertyTooltip' );
moveUp.FilePath = this.resource( 'moveUp' );

moveDown.Type = 'pushbutton';
moveDown.Tag = 'moveDown';
moveDown.Source = this;
moveDown.ObjectMethod = 'handleClickMovePropertyDown';
moveDown.DialogRefresh = true;
moveDown.RowSpan = [ 1, 1 ];
moveDown.ColSpan = [ 4, 4 ];
moveDown.Enabled = ~this.isLastPropertyInTable( currentProp );
moveDown.ToolTip = DAStudio.message( 'SystemArchitecture:ProfileDesigner:MoveDownPropertyTooltip' );
moveDown.FilePath = this.resource( 'moveDown' );

if this.isPrototypeSelectedInBrowser
row = row + 1;
showInherited.Type = 'checkbox';
showInherited.Tag = 'showInheritedPropsCheckbox';
showInherited.Name = DAStudio.message( 'SystemArchitecture:ProfileDesigner:ShowInheritedProperties' );
showInherited.Value = this.ShowInheritedStereotypeProperties;
showInherited.Source = this;
showInherited.ObjectMethod = 'setShowInheritedStereotypeProperties';
showInherited.MethodArgs = { '%value' };
showInherited.ArgDataTypes = { 'mxArray' };
showInherited.Mode = true;
showInherited.DialogRefresh = true;
showInherited.RowSpan = [ row, row ];
showInherited.ColSpan = [ 1, 5 ];
showInherited.ToolTip = DAStudio.message( 'SystemArchitecture:ProfileDesigner:ShowInheritedPropertiesTooltip' );
end 
schema.Type = 'group';
schema.Name = '';
if this.isPrototypeSelectedInBrowser
schema.Items = { addProp, deleteProp, moveUp, moveDown, propTable, showInherited };
schema.RowStretch = [ 0, 1, 0 ];
else 
schema.Items = { addProp, deleteProp, moveUp, moveDown, propTable };
schema.RowStretch = [ 0, 1 ];
end 
schema.LayoutGrid = [ row, 5 ];
schema.ColStretch = [ 0, 0, 0, 0, 1 ];
end 

function schema = getStatusBarSchema( this )


status.Type = 'text';
status.Tag = 'txtStatus';
status.RowSpan = [ 1, 1 ];
status.ColSpan = [ 1, 1 ];

if ~isempty( strfind( this.StatusMsg, 'SystemArchitecture:ProfileDesigner' ) )
status.Name = DAStudio.message( this.StatusMsg );
else 
status.Name = this.StatusMsg;
end 

if this.StatusIsError
status.ForegroundColor = [ 255, 0, 0 ];
end 
this.consumeStatus(  );

schema.Type = 'group';
schema.Name = '';
schema.Items = { status };

end 

function filepath = resource( ~, filename )

filepath = fullfile( matlabroot, 'toolbox', 'sysarch', 'sysarch', '+systemcomposer', '+internal', '+profile', 'resources', [ filename, '.png' ] );
end 

function is = isProfileSelectedInBrowser( this )


if isempty( this.CurrentTreeNode )
is = false;
return ;
end 
is = isempty( strfind( this.CurrentTreeNode, '/' ) );
end 

function is = isPrototypeSelectedInBrowser( this )


if isempty( this.CurrentTreeNode )
is = false;
return ;
end 
strs = strsplit( this.CurrentTreeNode, '/' );
is = false;
if length( strs ) > 1
if this.isFeatureEnabled( 'ZCPropertySets' )
if length( strs ) == 3
is = strcmp( strs{ 2 }, DAStudio.message( 'SystemArchitecture:ProfileDesigner:StereotypeNodeName' ) );
else 

is = false;
end 
else 
is = true;
end 
end 
end 

function is = isPropertySetSelectedInBrowser( this )


if isempty( this.CurrentTreeNode )
is = false;
return ;
end 
strs = strsplit( this.CurrentTreeNode, '/' );
is = false;
if length( strs ) > 1
if this.isFeatureEnabled( 'ZCPropertySets' )
if length( strs ) == 3
is = strcmp( strs{ 2 }, DAStudio.message( 'SystemArchitecture:ProfileDesigner:PropertySetNodeName' ) );
else 

is = false;
end 
end 
end 
end 

function b = isPrototype( ~, prototype )
b = isa( prototype, 'systemcomposer.internal.profile.Prototype' );
end 

function b = isPropertySet( ~, propSet )
b = isa( propSet, 'systemcomposer.property.PropertySet' );
end 

function setCurrentTreeNode( this, val )



this.CurrentTreeNode = strrep( val, '*', '' );

if this.isProfileSelectedInBrowser(  )
this.CurrentTreeSource = this.getProfile( this.CurrentTreeNode );
elseif this.isPrototypeSelectedInBrowser(  )
this.CurrentTreeSource = this.getPrototype( this.CurrentTreeNode );
elseif this.isPropertySetSelectedInBrowser(  )
this.CurrentTreeSource = this.getPropertySet( this.CurrentTreeNode );
else 
this.CurrentTreeSource = [  ];
end 
end 

function obj = getProfile( this, name )



obj = [  ];
for idx = 1:length( this.ProfileModels )
mdl = this.ProfileModels( idx );
p = systemcomposer.internal.profile.Profile.getProfile( mdl );
if strcmp( p.getName, name )
obj = p;
break ;
end 
end 
end 
function valTypes = getValueTypes( this )



valTypes = {  };
profiles = this.allProfiles;
if ~isempty( profiles )
valTypes = profiles( 1 ).valueTypes;
end 
end 

function obj = getPrototype( this, prototypePath, delim )




obj = [  ];
if nargin < 3
delim = '/';
end 
if strcmp( delim, '.' )
[ profileName, remainingStr ] = strtok( prototypePath, delim );
prototypeName = strtok( remainingStr( 2:end  ), delim );
else 
[ profileName, remainingStr ] = strtok( prototypePath, delim );
if this.isFeatureEnabled( 'ZCPropertySets' )
[ ~, prototypeName ] = strtok( remainingStr( 2:end  ), delim );
else 
prototypeName = remainingStr;
end 
prototypeName = prototypeName( 2:end  );
end 

profile = this.getProfile( profileName );
prototypes = profile.prototypes.toArray;

for idx = 1:length( prototypes )
p = prototypes( idx );
if strcmp( p.getName, prototypeName )
obj = p;
break ;
end 
end 
end 

function obj = getPropertySet( this, propSetPath, delim )




obj = [  ];
if nargin < 3
delim = '/';
end 

[ profileName, remainingStr ] = strtok( propSetPath, delim );
[ ~, propSetName ] = strtok( remainingStr( 2:end  ), delim );
propSetName = propSetName( 2:end  );

profile = this.getProfile( profileName );
propSets = profile.propertySets.toArray;

for idx = 1:length( propSets )
p = propSets( idx );
if strcmp( p.getName, propSetName )
obj = p;
break ;
end 
end 
end 

function entries = getBasePrototypeEntries( this )



entries = { '<nothing>' };
for idx = 1:length( this.ProfileModels )
m = this.ProfileModels( idx );
p = systemcomposer.internal.profile.Profile.getProfile( m );
if ~strcmp( p.getName(  ), 'systemcomposer' )
prototypeFQNs = arrayfun( @( x )x.fullyQualifiedName, p.prototypes.toArray, 'uniformoutput', false );
entries = [ entries, prototypeFQNs ];
end 
end 



currentPrototype = this.CurrentTreeSource.fullyQualifiedName;
entries( strcmp( currentPrototype, entries ) ) = [  ];
end 

function val = getPrototypeBaseValue( this )



prototype = this.CurrentTreeSource;
if isempty( prototype.parent )
val = 0;
else 
base = prototype.parent.fullyQualifiedName;
entries = this.getBasePrototypeEntries(  );
val = find( strcmp( base, entries ) );
if isempty( val )
MSLDiagnostic( 'SystemArchitecture:ProfileDesigner:CouldNotFindBasePrototype', base ).reportAsWarning;
val = 0;
else 
val = val - 1;
end 
end 
end 

function entries = getMetaclassEntries( obj )
entries = {  ...
'<all>',  ...
'Component',  ...
'Port',  ...
'Connector',  ...
'Interface',  ...
'Function' };

entries = [ entries, obj.metaConfig.getMetaTypes(  ) ];
end 

function val = getPrototypeExtendsValue( this )


prototype = this.CurrentTreeSource;
base = prototype.getExtendedElement(  );

if isempty( base )
val = 0;
else 
entries = this.getMetaclassEntries(  );
val = find( strcmp( base, entries ) ) - 1;
end 
end 

function filepath = getCurrentPrototypeIcon( this )
filepath = '';
prototype = this.CurrentTreeSource;
if ~isempty( prototype.icon )
iconName = systemcomposer.internal.profile.internal.PrototypeIconPicker.iconEnum2Name( prototype.icon );
if systemcomposer.internal.profile.PrototypeIcon.CUSTOM ~= prototype.icon
filepath = systemcomposer.internal.profile.internal.PrototypeIconPicker.iconName2FilePath( iconName, prototype.getExtendedElement );
else 
try 
filepath = prototype.getCustomIconPath;
catch ex
MSLDiagnostic( 'SystemArchitecture:ProfileDesigner:CustomIconError', ex.message ).reportAsWarning;
end 
end 
end 
end 

function RGBValue = getPaletteColorFromComponentHeaderColor( this )
prototype = this.CurrentTreeSource;
rgbaValue = prototype.getComponentHeaderColorInRGB;
rgbValue = transpose( rgbaValue( 1:3 ) );
RGBValue = systemcomposer.internal.profile.internal.PrototypeColorPicker.getPaletteColor( rgbValue );
end 

function RGBValue = getPaletteColorFromLineColor( this )
prototype = this.CurrentTreeSource;
rgbaValue = prototype.getConnectorLineColorInRGB;
rgbValue = transpose( rgbaValue( 1:3 ) );
RGBValue = systemcomposer.internal.profile.internal.PrototypeLineColorPicker.getPaletteColor( rgbValue );
end 

function filePath = getCurrentPrototypeLineStyleFilePath( this )
prototype = this.CurrentTreeSource;
filePath = systemcomposer.internal.profile.internal.PrototypeLineStylePicker.lineStyleEnum2FilePath( prototype.connectorLineStyle );
end 

function yesno = currentPrototypeAppliesToComponentOrArchitecture( this )



prototype = this.CurrentTreeSource;
list = prototype.getCumulativeAppliesTo(  );
yesno = any( strcmpi( list, 'Component' ) ) ||  ...
any( strcmpi( list, 'Architecture' ) );
end 

function yesno = currentPrototypeAppliesToPort( this )



prototype = this.CurrentTreeSource;
list = prototype.getCumulativeAppliesTo(  );
yesno = any( strcmpi( list, 'Port' ) );
end 

function yesno = currentPrototypeAppliesToInterface( this )



prototype = this.CurrentTreeSource;
list = prototype.getCumulativeAppliesTo(  );
yesno = any( strcmpi( list, 'Interface' ) );
end 

function yesno = currentPrototypeAppliesToConnector( this )



prototype = this.CurrentTreeSource;
list = prototype.getCumulativeAppliesTo(  );
yesno = any( strcmpi( list, 'Connector' ) );
end 

function yesno = currentPrototypeAppliesToComponent( this )


prototype = this.CurrentTreeSource;
element = prototype.getExtendedElement(  );
yesno = strcmpi( element, 'Component' );
end 

function propData = getCurrentPrototypePropertyTableData( this )


assert( this.isPrototypeSelectedInBrowser(  ) || this.isPropertySetSelectedInBrowser(  ) );
if this.isPrototype( this.CurrentTreeSource )
prototype = this.CurrentTreeSource;
showInherited = this.ShowInheritedStereotypeProperties;
propData = recursivelyGetPrototypeProps( prototype );
elseif this.isPropertySet( this.CurrentTreeSource )
propSet = this.CurrentTreeSource;
props = propSet.properties.toArray;
propData = getPropData( props );
end 

function propData = recursivelyGetPrototypeProps( proto )
if isempty( proto.propertySet )
props = {  };
else 
props = proto.propertySet.properties.toArray;
end 
propData = getPropData( props );
if showInherited && ~isempty( proto.parent )
subData = recursivelyGetPrototypeProps( proto.parent );
subData = cellfun( @( x )setfield( x, 'Enabled', false ), subData, 'uniformoutput', false );
propData = [ propData;subData ];
end 
end 

function propData = getPropData( props )
propData = cell( length( props ), 5 );
for idx = 1:length( props )
p = props( idx );

propData{ idx, 1 } = this.getPropertyNameSchema( p );
propData{ idx, 2 } = this.getPropertyTypeSchema( p );
propData{ idx, 3 } = this.getPropertyOptionsSchema( p );
propData{ idx, 4 } = this.getPropertyUnitsSchema( p );
propData{ idx, 5 } = this.getPropertyDefaultValueSchema( p );
end 
end 
end 

function schema = getPropertyNameSchema( ~, prop )


schema.Type = 'edit';
schema.Value = prop.getName;
end 

function schema = getPropertyTypeSchema( this, prop )


switch class( prop.type )
case 'systemcomposer.property.StringType'
case 'systemcomposer.property.FloatType'
case 'systemcomposer.property.IntegerType'
case 'systemcomposer.property.BooleanType'
case 'systemcomposer.property.Enumeration'
case 'systemcomposer.property.StringArrayType'
otherwise 
error( 'Unsupported property of type: %s', class( prop ) );
end 
schema.Type = 'combobox';
entries = this.getPropertyTypeEntries(  );
schema.Entries = entries;
if ( isa( prop.type, 'systemcomposer.property.Enumeration' ) )
ind = length( entries );
else 
typeName = prop.type.getName(  );
if isempty( typeName ) && ~isempty( prop.getBaseType )
typeName = prop.getBaseType;
end 
ind = find( ismember( entries, typeName ) );
end 
schema.Value = ind - 1;
end 

function schema = getPropertyOptionsSchema( this, prop )


schema.Type = 'edit';
if isa( prop.type, 'systemcomposer.property.Enumeration' )
schema.Value = this.enumPropOptionsToString( prop );
else 
schema.Value = 'n/a';
schema.Enabled = false;
end 
end 

function schema = getPropertyUnitsSchema( ~, prop )


schema.Type = 'edit';
schema.Value = 'n/a';
schema.Enabled = false;

switch class( prop.type )
case { 'systemcomposer.property.StringType',  ...
'systemcomposer.property.StringArrayType',  ...
'systemcomposer.property.BooleanType',  ...
'systemcomposer.property.Enumeration' }

case { 'systemcomposer.property.FloatType',  ...
'systemcomposer.property.IntegerType' }
schema.Value = prop.type.units;
schema.Enabled = true;
otherwise 
error( 'Unsupported property of type: %s', class( prop ) );
end 
end 

function schema = getPropertyDefaultValueSchema( ~, prop )


switch class( prop.type )
case 'systemcomposer.property.StringType'
schema.Type = 'edit';
schema.Value = prop.defaultValue.expression;
case 'systemcomposer.property.StringArrayType'
schema.Type = 'edit';
schema.Value = prop.defaultValue.expression;
schema.Enabled = false;
case { 'systemcomposer.property.FloatType',  ...
'systemcomposer.property.IntegerType' }
schema.Type = 'edit';
val = prop.defaultValue.expression;
if isempty( val )
val = num2str( prop.defaultValue.getValue );
end 
schema.Value = val;
case 'systemcomposer.property.BooleanType'
schema.Type = 'checkbox';
schema.Value = double( prop.defaultValue.getValue );
case 'systemcomposer.property.Enumeration'
schema.Type = 'combobox';
try 


enumName = prop.type.MATLABEnumName;
if ( ~systemcomposer.property.Enumeration.isValidEnumerationName( enumName ) )
schema.Entries = cell( 1, 1 );
schema.Value = 0;


dp = DAStudio.DialogProvider;
dp.warndlg(  ...
DAStudio.message( 'SystemArchitecture:Property:InvalidIllDefinedEnum', enumName ),  ...
DAStudio.message( 'SystemArchitecture:Property:InvalidEnum' ),  ...
true );
return ;
else 


schema.Entries = prop.type.getLiteralsAsStrings(  );
val = prop.defaultValue.getValue;
valString = char( val );
if ~strcmp( eval( prop.defaultValue.expression ), valString )
storedExpression = eval( prop.defaultValue.expression );
schema.Entries{ end  + 1 } = storedExpression;
schema.Value = length( schema.Entries ) - 1;


dp = DAStudio.DialogProvider;
dp.warndlg(  ...
DAStudio.message( 'SystemArchitecture:Property:InvalidDefaultEnumPropValue', storedExpression, prop.fullyQualifiedName ),  ...
DAStudio.message( 'SystemArchitecture:Property:InvalidEnumPropValue' ),  ...
true );
else 
ind = find( ismember( schema.Entries, valString ) );
schema.Value = ind - 1;
end 
end 
catch ME
valString = prop.defaultValue.expression;
schema.Entries{ end  + 1 } = eval( valString );
schema.Value = length( schema.Entries ) - 1;


dp = DAStudio.DialogProvider;
dp.warndlg(  ...
DAStudio.message( 'SystemArchitecture:Property:InvalidDefaultEnumPropValue', valString, prop.fullyQualifiedName ),  ...
ME.message,  ...
true );
end 
otherwise 
error( 'Unsupported property of type: %s', class( prop ) );
end 
end 

function propTypeStrs = getPropertyTypeEntries( this )


propTypeStrs = {  };
valueTypes = this.getValueTypes;

valueTypesArr = valueTypes.toArray;
for v = 1:length( valueTypesArr )
name = valueTypesArr( v ).getName(  );
if ~strcmp( name, 'stringArray' )


propTypeStrs{ end  + 1 } = name;
end 
end 
propTypeStrs{ end  + 1 } = 'enumeration';
end 

function setStatus( this, msg, isError )


if nargin < 3
isError = 'none';
end 
this.StatusMsg = msg;
this.StatusIsError = strcmp( isError, 'error' );
end 

function consumeStatus( this )


this.StatusMsg = '';
this.StatusIsError = false;
end 

function name = generateNewPropertyName( this )


currSrc = this.CurrentTreeSource;
isStereotype = this.isPrototype( currSrc );
isPropSet = this.isPropertySet( currSrc );
root = 'Property';
idx = 1;
while idx < 500
try 
name = strcat( root, num2str( idx ) );
if isStereotype
currSrc.checkPropertyNameAcrossHierarchy( name );
break ;
elseif isPropSet
currSrc.checkPropertyNameUniqueness( name );
break ;
end 
catch ex %#ok<NASGU>
idx = idx + 1;
end 
end 
end 

function name = generateNewProfileName( this )


names = cell( length( this.ProfileModels ), 1 );
for idx = 1:length( this.ProfileModels )
m = this.ProfileModels( idx );
profile = systemcomposer.internal.profile.Profile.getProfile( m );
names{ idx } = profile.getName;
end 

name = 'Profile';
name = this.uniquifyName( name, names );
end 

function name = generateNewPrototypeName( this )


profile = this.getCurrentProfile(  );
assert( ~isempty( profile ) );
names = profile.prototypes.keys;
name = 'Stereotype';
name = this.uniquifyName( name, names );
end 

function name = generateNewPropertySetName( this )


profile = this.getCurrentProfile(  );
assert( ~isempty( profile ) );
names = profile.propertySets.keys;
name = 'PropertySet';
name = this.uniquifyName( name, names );
end 

function name = uniquifyName( ~, name, names )


count = 1;
while ~isempty( intersect( name, names ) )

toks = regexp( name, '([a-zA-Z_]+)([0-9]+)', 'tokens' );
if ~isempty( toks ) && ~isempty( toks{ 1 }{ 2 } )
numPart = toks{ 1 }{ 2 };

count = count + 1;
name = [ name( 1:end  - length( numPart ) ), num2str( count ) ];
else 

name = [ name, num2str( count ) ];
end 
end 
end 

function txn = beginTransaction( ~, elem )
mdl = mf.zero.getModel( elem );
txn = mdl.beginTransaction(  );
end 

function commitTransaction( this, elem, fcn )
txn = this.beginTransaction( elem );
fcn(  );
txn.commit(  );
end 

function str = enumPropOptionsToString( ~, prop )
str = prop.type.MATLABEnumName;
end 

function closeProfile( this, profileName )

systemcomposer.internal.profile.Profile.unload( profileName );


this.resetUIState(  );
end 

function saveUnsavedProfiles( this )


for idx = 1:length( this.ProfileModels )
m = this.ProfileModels( idx );
profile = systemcomposer.internal.profile.Profile.getProfile( m );
if profile.dirty
profile.saveToFile(  );
end 
end 
end 

function discardUnsavedProfiles( this )





%#ok<*AGROW>

toClose = [  ];
for idx = 1:length( this.ProfileModels )
m = this.ProfileModels( idx );
profile = systemcomposer.internal.profile.Profile.getProfile( m );
if profile.dirty
[ hasUsages, usages ] = this.profileHasOpenUsages( profile );
if hasUsages

dp = DAStudio.DialogProvider;
dp.warndlg(  ...
DAStudio.message( 'SystemArchitecture:ProfileDesigner:ProfileHasOpenUsages',  ...
profile.getName(  ), strjoin( usages, ''', ''' ) ),  ...
DAStudio.message( 'SystemArchitecture:ProfileDesigner:CannotCloseProfile' ),  ...
true );
else 
reopenPath = profile.filePath;
toClose = [ toClose,  ...
struct( 'profileName', profile.getName(  ), 'reopenPath', reopenPath ) ];
end 
end 
end 

for idx = 1:length( toClose )
item = toClose( idx );
this.closeProfile( item.profileName );
if ~isempty( item.reopenPath )
systemcomposer.internal.profile.Profile.loadFromFile( item.reopenPath );
end 
end 
end 

function filterList = getProfileFilterList( this )


archMdlsAndDDs = this.getOpenArchitectureModelsAndDictionaries(  );
filterList = [ { this.ALL };archMdlsAndDDs;{ this.REFRESH } ];

this.CachedProfileFilterList = filterList;
end 

function mdlsAndDDs = getOpenArchitectureModelsAndDictionaries( ~ )


mdlsAndDDs = {  };
if is_simulink_loaded
allmdls = find_system( 'Type', 'block_diagram', 'BlockDiagramType', 'model' );
subsystems = find_system( 'Type', 'block_diagram', 'BlockDiagramType', 'subsystem' );
allmdls = [ allmdls;subsystems ];

allmdls = sort( allmdls );
for idx = 1:length( allmdls )
mdl = allmdls{ idx };
isArch = strcmpi( get_param( mdl, 'sysarch_app_plugin' ), 'on' );
if isArch

mdlsAndDDs = [ mdlsAndDDs;{ [ mdl, '.slx' ] } ];
end 
end 

allDDs = Simulink.data.dictionary.getOpenDictionaryPaths;
for idx = 1:numel( allDDs )
ddName = allDDs{ idx };
[ ~, fName, fExt ] = fileparts( ddName );
mdlsAndDDs = [ mdlsAndDDs;{ [ fName, fExt ] } ];
end 
end 


partiallyLoadedZCModels = systemcomposer.architecture.model.SystemComposerModel.getSystemComposerModels( systemcomposer.architecture.model.core.ModelLoadState.PARTIALLY_LOADED );
for idx = 1:numel( partiallyLoadedZCModels )
currZCModel = partiallyLoadedZCModels( idx );

mdlsAndDDs = [ mdlsAndDDs;{ [ ( currZCModel.getName ), '.slx' ] } ];
end 


mdlsAndDDs = unique( mdlsAndDDs, 'stable' );
end 

function open = isArchModelOpen( ~, archModelOrDD )

mdl = systemcomposer.architecture.model.SystemComposerModel.findSystemComposerModel( archModelOrDD );
open = ~isempty( mdl );
end 

function open = isDictionaryOpen( ~, archModelOrDD )

open = false;

openedDDs = Simulink.data.dictionary.getOpenDictionaryPaths(  );
for idx = 1:numel( openedDDs )
openDD = openedDDs{ idx };
[ ~, fName, ~ ] = fileparts( openDD );
if strcmp( fName, archModelOrDD )
open = true;
break ;
end 
end 
end 

function open = isArchModelOrDDOpen( this, archModelOrDD )





[ isModel, modelOrDDName ] = this.isModelContext( archModelOrDD );

if isModel

open = this.isArchModelOpen( modelOrDDName );
else 
open = this.isDictionaryOpen( modelOrDDName );
end 
end 

function is = isFilteringProfilesByModelOrDD( this )



is = ~strcmpi( this.ProfileFilter, this.ALL );
end 

function [ profiles, hasMore ] = getProfilesInFilter( this )

hasMore = false;

if ~this.isFilteringProfilesByModelOrDD(  )

profiles = this.allProfiles(  );

else 


[ isModel, modelOrDDName ] = this.isModelContext( this.ProfileFilter );
zcModel = systemcomposer.architecture.model.SystemComposerModel.findSystemComposerModel( modelOrDDName );


if ~this.isArchModelOrDDOpen( this.ProfileFilter ) && ( isempty( zcModel ) )

this.ProfileFilter = this.ALL;
profiles = this.allProfiles;
else 
if isModel

profiles = systemcomposer.internal.profile.Profile.empty;
profilesInModel = zcModel.getProfiles;
idx = 1;
for i = 1:numel( profilesInModel )

if ~strcmp( profilesInModel( i ).getName, "systemcomposer" )
profiles( idx ) = profilesInModel( i );
idx = idx + 1;
end 
end 
else 

ddConn = Simulink.data.dictionary.open( this.ProfileFilter );
mf0Model = Simulink.SystemArchitecture.internal.DictionaryRegistry.FetchInterfaceSemanticModel( ddConn.filepath(  ) );
zcModel = systemcomposer.architecture.model.SystemComposerModel.getSystemComposerModel( mf0Model );
piCatalog = zcModel.getPortInterfaceCatalog;
profiles = piCatalog.getProfiles;

profiles = profiles( ~[ profiles.isMathWorksProfile ] );
end 
hasMore = ( length( profiles ) < length( this.ProfileModels ) );
end 
end 
end 

function profiles = allProfiles( this )

profiles = [  ];
for idx = 1:length( this.ProfileModels )
m = this.ProfileModels( idx );
profile = systemcomposer.internal.profile.Profile.getProfile( m );
profiles = cat( 1, profiles, profile );
end 

end 

function checkoutLicense( ~ )


ok = license( 'checkout', 'System_Composer' );
if ~ok
DAStudio.error( 'SystemArchitecture:ProfileDesigner:NeedsSystemComposerLicense' );
end 
end 

function hasErr = profileSave( this, profile, fullPath, dlg, postSaveFcn )

if nargin < 5
postSaveFcn = [  ];
end 
try 
profile.saveToFile( fullPath );
this.setStatus( DAStudio.message( 'SystemArchitecture:ProfileDesigner:SavedProfile', profile.getName ) );
hasErr = false;
catch me
dp = DAStudio.DialogProvider;
eDlg = dp.errordlg(  ...
DAStudio.message( 'SystemArchitecture:ProfileDesigner:ErrorSavingProfileMsg', me.message ),  ...
DAStudio.message( 'SystemArchitecture:ProfileDesigner:ErrorSavingProfile' ),  ...
true );
this.positionDialog( eDlg, dlg );
hasErr = true;
end 

if isa( postSaveFcn, 'function_handle' )
postSaveFcn(  );
end 

if ~isempty( dlg )
dlg.refresh(  );
end 
this.DialogInstance.refresh;
end 

function profileSaveAs( this, profile, dlg, postSaveFcn )

if nargin < 4
postSaveFcn = [  ];
end 


[ fname, fpath ] = uiputfile( '*.xml',  ...
DAStudio.message( 'SystemArchitecture:ProfileDesigner:SaveAsTitle' ),  ...
profile.getName(  ) );
if isequal( fname, 0 ) || isequal( fpath, 0 )

return ;
end 
fullPath = fullfile( fpath, fname );



newName = strrep( fname, '.xml', '' );
if ~strcmp( newName, profile.getName(  ) )
dp = DAStudio.DialogProvider;
eDlg = dp.questdlg(  ...
DAStudio.message( 'SystemArchitecture:ProfileDesigner:RenameProfileQuestion', profile.getName(  ), newName ),  ...
DAStudio.message( 'SystemArchitecture:ProfileDesigner:RenameProfileTitle' ),  ...
{ DAStudio.message( 'SystemArchitecture:ProfileDesigner:RenameProfileYes' ),  ...
DAStudio.message( 'SystemArchitecture:ProfileDesigner:RenameProfileNo' ) },  ...
DAStudio.message( 'SystemArchitecture:ProfileDesigner:RenameProfileNo' ),  ...
@( resp )handleResponse( resp, dlg, profile, newName, fullPath, postSaveFcn ) );
this.positionDialog( eDlg, dlg );

else 

this.profileSave( profile, fullPath, dlg, postSaveFcn );
end 

function handleResponse( response, dlg, profile, newName, fullPath, postSaveFcn )
if strcmp( response, DAStudio.message( 'SystemArchitecture:ProfileDesigner:RenameProfileYes' ) )
profile.setName( newName );
else 

return ;
end 


this.profileSave( profile, fullPath, dlg, postSaveFcn );
end 
end 

function [ hasUsages ] = profileHasOpenUsagesInScrapArch( ~, profile )
hasUsages = false;
try 
scrapArch = Simulink.SystemArchitecture.internal.ApplicationManager.getScrapArchitecture;
mfModel = mf.zero.getModel( scrapArch );
scrapArchModel = systemcomposer.architecture.model.SystemComposerModel.getSystemComposerModel( mfModel );
scrapArchProfiles = scrapArchModel.getProfiles;
for idx = 1:numel( scrapArchProfiles )
if ( scrapArchProfiles( idx ).getName(  ) == profile.getName(  ) )
hasUsages = true;
return ;
end 
end 
catch 


end 
end 

function importProfileIntoOpenModelOrDD( this, profile, fileName )





[ isModel, modelOrDDName ] = this.isModelContext( fileName );

if isModel
zcModelImpl = systemcomposer.architecture.model.SystemComposerModel.findSystemComposerModel( modelOrDDName );
rootArch = zcModelImpl.getRootArchitecture;
mfModel = mf.zero.getModel( rootArch );
txn = mfModel.beginTransaction;
rootArch.p_Model.addProfile( profile.getName );
txn.commit;
msgTag = 'SystemArchitecture:ProfileDesigner:ImportedProfileIntoModel';
else 
ddConn = Simulink.data.dictionary.open( fileName );
mf0Model = Simulink.SystemArchitecture.internal.DictionaryRegistry.FetchInterfaceSemanticModel( ddConn.filepath(  ) );
zcModel = systemcomposer.architecture.model.SystemComposerModel.getSystemComposerModel( mf0Model );
piCatalog = zcModel.getPortInterfaceCatalog;
piCatalog.addProfile( profile.getName );
msgTag = 'SystemArchitecture:ProfileDesigner:ImportedProfileIntoDictionary';
end 

this.setStatus( DAStudio.message( msgTag, profile.getName(  ),  ...
modelOrDDName ) );
end 

function has = modelHasProfileAlready( ~, profile, modelName )



zcModel = systemcomposer.architecture.model.SystemComposerModel.findSystemComposerModel( modelName );
rootArch = zcModel.getRootArchitecture;
profiles = rootArch.p_Model.getProfiles(  );
names = arrayfun( @( x )x.getName, profiles, 'uniformoutput', false );
has = any( strcmp( profile.getName(  ), names ) );
end 

function has = dictionaryHasProfileAlready( ~, profileName, ddName )


ddConn = Simulink.data.dictionary.open( ddName );
mf0Model = Simulink.SystemArchitecture.internal.DictionaryRegistry.FetchInterfaceSemanticModel( ddConn.filepath(  ) );
zcModel = systemcomposer.architecture.model.SystemComposerModel.getSystemComposerModel( mf0Model );
piCatalog = zcModel.getPortInterfaceCatalog;
has = ~isempty( piCatalog.getProfile( profileName ) );
end 

function [ protoList, currentValue ] = getArchitecturePrototypes( this )
protoList = { DAStudio.message( 'SystemArchitecture:ProfileDesigner:none' ) };
src = this.CurrentTreeSource;
currentValue = '';
if isa( src, 'systemcomposer.internal.profile.Profile' )
profile = src;
proto = profile.defaultArchPrototype;
if ~isempty( proto )
currentValue = proto.getName;
end 
elseif isa( src, 'systemcomposer.internal.profile.Prototype' )
profile = src.profile;
end 

prototypes = profile.prototypes.toArray;
for i = 1:numel( prototypes )
if ~prototypes( i ).abstract && ( this.isPrototypeType( prototypes( i ), 'Component' ) ...
 || isempty( prototypes( i ).appliesTo.toArray ) )
protoList{ end  + 1 } = prototypes( i ).getName;
end 
end 
proto = this.CurrentTreeSource;
if isa( proto, 'systemcomposer.internal.profile.Prototype' ) && this.isPrototypeType( proto, 'Component' )
archDefault = {  };
if ~isempty( proto.defaultStereotypeMap )
archDefault = proto.defaultStereotypeMap.getArchitectureDefault;
end 
currentValue = '';
if ~isempty( archDefault )
currentValue = archDefault.getName;
end 
end 
end 


function [ protoList, currentValue ] = getPortPrototypes( this )
protoList = { DAStudio.message( 'SystemArchitecture:ProfileDesigner:none' ) };
currentValue = '';
src = this.CurrentTreeSource;
if isa( src, 'systemcomposer.internal.profile.Profile' )
profile = src;
elseif isa( src, 'systemcomposer.internal.profile.Prototype' )
profile = src.profile;
end 
prototypes = profile.prototypes.toArray;
for i = 1:numel( prototypes )
if ~prototypes( i ).abstract && ( this.isPrototypeType( prototypes( i ), 'Port' ) ...
 || isempty( prototypes( i ).appliesTo.toArray ) )
protoList{ end  + 1 } = prototypes( i ).getName;
end 
end 

proto = this.CurrentTreeSource;

if isa( proto, 'systemcomposer.internal.profile.Prototype' ) && this.isPrototypeType( proto, 'Component' )
portDefault = {  };
if ~isempty( proto.defaultStereotypeMap )
portDefault = proto.defaultStereotypeMap.getPortDefault;
end 
if ~isempty( portDefault )
currentValue = portDefault.getName;
end 
end 
end 

function [ protoList, currentValue ] = getConnectorPrototypes( this )
protoList = { DAStudio.message( 'SystemArchitecture:ProfileDesigner:none' ) };
currentValue = '';
src = this.CurrentTreeSource;
if isa( src, 'systemcomposer.internal.profile.Profile' )
profile = src;
elseif isa( src, 'systemcomposer.internal.profile.Prototype' )
profile = src.profile;
end 
prototypes = profile.prototypes.toArray;
for i = 1:numel( prototypes )
if ~prototypes( i ).abstract && ( this.isPrototypeType( prototypes( i ), 'Connector' ) ...
 || isempty( prototypes( i ).appliesTo.toArray ) )
protoList{ end  + 1 } = prototypes( i ).getName;
end 
end 

proto = this.CurrentTreeSource;
if isa( proto, 'systemcomposer.internal.profile.Prototype' ) && this.isPrototypeType( proto, 'Component' )
connDefault = {  };
if ~isempty( proto.defaultStereotypeMap )
connDefault = proto.defaultStereotypeMap.getConnectorDefault;
end 
if ~isempty( connDefault )
currentValue = connDefault.getName;
end 
end 
end 

function [ protoList, currentValue ] = getFunctionPrototypes( this )
protoList = { DAStudio.message( 'SystemArchitecture:ProfileDesigner:none' ) };
currentValue = '';
src = this.CurrentTreeSource;
if isa( src, 'systemcomposer.internal.profile.Profile' )
profile = src;
elseif isa( src, 'systemcomposer.internal.profile.Prototype' )
profile = src.profile;
end 
prototypes = profile.prototypes.toArray;
for i = 1:numel( prototypes )
if ~prototypes( i ).abstract && ( this.isPrototypeType( prototypes( i ), 'Function' ) ...
 || isempty( prototypes( i ).appliesTo.toArray ) )
protoList{ end  + 1 } = prototypes( i ).getName;
end 
end 

proto = this.CurrentTreeSource;
if isa( proto, 'systemcomposer.internal.profile.Prototype' ) && this.isPrototypeType( proto, 'Component' )
funcDefault = {  };
if ~isempty( proto.defaultStereotypeMap )
funcDefault = proto.defaultStereotypeMap.getFunctionDefault;
end 
if ~isempty( funcDefault )
currentValue = funcDefault.getName;
end 
end 
end 

function [ isModel, modelOrDDName ] = isModelContext( ~, fileName )


[ ~, modelOrDDName, ext ] = fileparts( fileName );
isModel = ~strcmpi( ext, '.sldd' );
end 

function propSet = getCurrentPropertySet( this )

prototype = this.CurrentTreeSource;
if this.isPrototype( prototype )
propSet = prototype.propertySet;
else 
propSet = prototype;
end 

end 

function tf = isFeatureEnabled( this, featureName )
tf = false;
if this.Context == systemcomposer.internal.profile.internal.ProfileEditorContext.Requirements


return ;
end 
tf = slfeature( featureName ) > 0;
end 
end 

methods ( Hidden )
function [ has, modelOrDDNames ] = profileHasOpenUsages( this, profile )


has = false;
modelOrDDNames = {  };

openMdlsOrDDs = this.getOpenArchitectureModelsAndDictionaries(  );
for idx = 1:length( openMdlsOrDDs )
fileName = openMdlsOrDDs{ idx };
[ ~, mdl, ext ] = fileparts( fileName );
if strcmpi( ext, '.sldd' ) &&  ...
this.dictionaryHasProfileAlready( profile.getName(  ),  ...
fileName )
has = true;
modelOrDDNames = [ modelOrDDNames, { fileName } ];
elseif ~strcmpi( ext, '.sldd' ) && this.modelHasProfileAlready( profile, mdl )
has = true;
modelOrDDNames = [ modelOrDDNames, { fileName } ];
end 
end 
end 
end 

end 





% Decoded using De-pcode utility v1.2 from file /tmp/tmpbDi3vE.p.
% Please follow local copyright laws when handling this file.

