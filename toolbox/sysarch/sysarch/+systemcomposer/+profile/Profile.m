classdef ( Sealed )Profile < systemcomposer.profile.internal.Element



















































properties ( Transient, Dependent )




Name;





FriendlyName;



Description;
end 

properties ( Transient, Dependent, SetAccess = private )





Stereotypes;

end 

properties ( Transient, Dependent, Hidden )
Dirty;
end 

properties ( Transient, Hidden )
IsMathWorksProfile logical = false
end 

methods ( Static )
function profile = createProfile( profileName, varargin )













profileImpl = systemcomposer.internal.profile.Profile.newProfile( profileName );
profile = systemcomposer.profile.Profile.wrapper( profileImpl );
profile.applyNameValuePairs( varargin{ : } );
end 

function profile = load( filename )








model = systemcomposer.internal.profile.Profile.loadFromFile( filename );
profileImpl = systemcomposer.internal.profile.Profile.getProfile( model );
profile = systemcomposer.profile.Profile.wrapper( profileImpl );
end 

function profile = find( profileName )









if nargin == 0

profImplArray = systemcomposer.internal.profile.Profile.getProfilesInCatalog(  );
profile = arrayfun( @( impl )systemcomposer.profile.Profile.wrapper( impl ), profImplArray );

else 

impl = systemcomposer.internal.profile.Profile.findLoadedProfile( profileName );
if isempty( impl )
profile = systemcomposer.profile.Profile.empty(  );
else 
profile = systemcomposer.profile.Profile.wrapper( impl );
end 
end 
end 

function closeAll(  )


systemcomposer.internal.profile.Profile.unload(  );
systemcomposer.internal.profile.Designer.unload(  );
end 
end 





methods 
function open( this )







systemcomposer.profile.editor( this );
end 

function stereotype = addStereotype( this, stereotypeName, nameValArgs )













R36
this
stereotypeName{ mustBeValidVariableName }
nameValArgs.?systemcomposer.profile.Stereotype
end 

txn = this.Model.beginTransaction;
sImpl = this.Impl.addPrototype( stereotypeName );
txn.commit;
stereotype = systemcomposer.profile.Stereotype.wrapper( sImpl );

names = fields( nameValArgs );
vals = struct2cell( nameValArgs );
args = [ names';vals' ];

stereotype.applyNameValuePairs( args{ : } );
end 

function removeStereotype( this, stereotypeNameOrObj )











if ischar( stereotypeNameOrObj ) || ( isstring( stereotypeNameOrObj ) && numel( stereotypeNameOrObj ) == 1 )
obj = this.getStereotype( stereotypeNameOrObj );

elseif isa( stereotypeNameOrObj, 'systemcomposer.profile.Stereotype' )
obj = stereotypeNameOrObj;

else 
error( message( 'SystemArchitecture:Profile:InputArgProfileNameOrObj' ) );
end 

txn = this.Model.beginTransaction;
obj.destroy(  );
txn.commit;
end 

function pSet = getPropertySet( this, pSetName )








psImpl = this.Impl.propertySets.getByKey( pSetName );
if isempty( psImpl )
error( message(  ...
'SystemArchitecture:Profile:CouldNotFindStereotypeInProfile',  ...
pSetName, this.Name ) );
end 
pSet = systemcomposer.profile.PropertySet.wrapper( psImpl );
end 

function stereotype = getStereotype( this, stereotypeName )








sImpl = this.Impl.prototypes.getByKey( stereotypeName );
if isempty( sImpl )
error( message(  ...
'SystemArchitecture:Profile:CouldNotFindStereotypeInProfile',  ...
stereotypeName, this.Name ) );
end 
stereotype = systemcomposer.profile.Stereotype.wrapper( sImpl );
end 

function filePath = save( this, dirPath )








currentFilePath = this.Impl.filePath;
filePath = '';
if isempty( currentFilePath ) && nargin == 2
filePath = [ dirPath, '/', this.Name, '.xml' ];
end 
filePath = this.Impl.saveToFile( filePath );
end 

function close( this, force )











if nargin < 2
force = false;
end 
if ~force && this.Dirty
error( message( 'SystemArchitecture:Profile:ProfileHasUnsavedChanges', this.Name ) );
end 
if this.hasOpenUsages(  )
error( message( 'SystemArchitecture:Profile:OpenModelsUsingProfile', this.Name ) );
end 

systemcomposer.internal.profile.Profile.unload( this.Name );
delete( this );
end 

function setDefaultStereotype( this, stereotypeName )







stereotype = getStereotype( this, stereotypeName );

txn = this.Model.beginTransaction;
this.getImpl.setDefaultPrototype( stereotype.getImpl );
txn.commit;

end 

function defaultSt = getDefaultStereotype( this )


defaultSt = systemcomposer.profile.Stereotype.empty;
sImpl = this.getImpl.defaultArchPrototype;
if ~isempty( sImpl )
defaultSt = systemcomposer.profile.Stereotype.wrapper( sImpl );
end 
end 

function exported_filename = exportToVersion( this, target_filename, version )













[ path, name, ext ] = fileparts( target_filename );
if contains( this.Impl.filePath, target_filename )
error( message( 'SystemArchitecture:Profile:CannotExportToPreviousSameName' ) );
end 

if isempty( path )
path = pwd;
end 

if isempty( ext )
ext = '.xml';
end 

targetFilePath = fullfile( path, [ name, ext ] );

try 
this.getImpl.exportToPrevious( version, targetFilePath );
catch ME
throwAsCaller( ME );
end 

exported_filename = targetFilePath;

end 






function set.Name( this, value )
txn = this.Model.beginTransaction;
this.Impl.setName( value );
txn.commit;
end 

function value = get.Name( this )
value = this.Impl.getName(  );
end 

function set.FriendlyName( this, value )
txn = this.Model.beginTransaction;
this.Impl.friendlyName = value;
txn.commit;
end 

function value = get.FriendlyName( this )
value = this.Impl.friendlyName;
end 

function set.Description( this, value )
txn = this.Model.beginTransaction;
this.Impl.description = value;
txn.commit;
end 

function value = get.Description( this )
value = this.Impl.description;
end 

function value = get.Dirty( this )
value = this.Impl.dirty;
end 

function stereotypes = get.Stereotypes( this )
impls = this.Impl.prototypes.toArray;
if isempty( impls )
stereotypes = systemcomposer.profile.Stereotype.empty(  );
else 
stereotypes = arrayfun( @( x )systemcomposer.profile.Stereotype.wrapper( x ), impls );
end 
end 

function tf = get.IsMathWorksProfile( this )
tf = this.Impl.isMathWorksProfile;
end 

function set.IsMathWorksProfile( this, val )
this.Impl.isMathWorksProfile = val;
end 

function destroy( this )





if ~isempty( this.Stereotypes )
error( message( 'SystemArchitecture:Profile:CannotDestroyProfileUseClose' ) );
end 
systemcomposer.internal.profile.Profile.unload( this.Name );
end 
end 





properties ( Transient, Constant, Access = private )
ImplClassName = 'systemcomposer.internal.profile.Profile';
end 

methods ( Static, Access = { ?systemcomposer.profile.Stereotype, ?systemcomposer.profile.PropertySet, ?systemcomposer.arch.Model, ?systemcomposer.interface.Dictionary, ?systemcomposer.allocation.AllocationSet } )
function profile = wrapper( impl )



assert( isa( impl, systemcomposer.profile.Profile.ImplClassName ) );
if ~isempty( impl.cachedWrapper ) && isvalid( impl.cachedWrapper )
profile = impl.cachedWrapper;
else 
profile = systemcomposer.profile.Profile( impl );
end 
end 
end 

methods ( Access = private )
function this = Profile( impl )



assert( isa( impl, systemcomposer.profile.Profile.ImplClassName(  ) ) );
this@systemcomposer.profile.internal.Element( impl );
end 

function has = hasOpenUsages( ~ )

has = false;
end 
end 
end 

% Decoded using De-pcode utility v1.2 from file /tmp/tmpL2vc6W.p.
% Please follow local copyright laws when handling this file.

