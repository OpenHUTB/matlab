classdef CompositeProducer < handle & coderapp.internal.config.AbstractProducer





properties ( SetAccess = immutable )
Factory char
FactoryArgs cell
MappingProperty char
BoundObjectKey char
SubstituteFactory char
ExcludeKeys cell
Reuse( 1, 1 )logical
Scriptify( 1, 1 )logical
ScriptVariable char
ScriptVariableKey char
end 

properties ( SetAccess = immutable, Dependent, Hidden )
AllPropertyMappings
end 

properties ( SetAccess = private, GetAccess = protected )
ScriptHelper coderapp.internal.config.util.CompositeScriptHelper
end 

properties ( SetAccess = private, Hidden )
UnmappedKeys
end 

properties ( Access = protected )
SyncBoundObject( 1, 1 )logical = false
SyncPollPeriod( 1, 1 ){ mustBeGreaterThanOrEqual( SyncPollPeriod, 1 ) } = 4
SyncBoundAsUser( 1, 1 )logical = true
SyncBoundWithValidation( 1, 1 )logical = false
IgnoreSetterErrors( 1, 1 )logical = false
end 

properties ( Access = private, Transient )
KeyToProperty
FilteredKeys
PollingTimer
BoundObject
end 

methods 
function this = CompositeProducer( factory, varargin )
R36
factory{ mustBeTextScalar( factory ) }
end 
R36( Repeating )
varargin
end 

persistent ip;
if isempty( ip )
ip = inputParser(  );
ip.addParameter( 'FactoryArgs', {  }, @iscell );
ip.addParameter( 'MappingMetaProperty', 'objectProperty', @coderapp.internal.util.isScalarText );
ip.addParameter( 'Reuse', true, @islogical );
ip.addParameter( 'BoundObjectKey', '', @coderapp.internal.util.isScalarText );
ip.addParameter( 'SubstituteFactory', '', @( f )coderapp.internal.util.isScalarText( f ) && ~isempty( which( f ) ) );
ip.addParameter( 'ExcludeKeys', {  }, @iscellstr );
ip.addParameter( 'SyncBoundObject', false, @islogical );
ip.addParameter( 'SyncBoundWithValidation', false, @islogical );
ip.addParameter( 'SyncBoundAsUser', true, @islogical );
ip.addParameter( 'Scriptify', true, @islogical );
ip.addParameter( 'ScriptVariable', '', @ischar );
ip.addParameter( 'ScriptVariableKey', '', @ischar );
end 
ip.parse( varargin{ : } );
opts = ip.Results;
ip.parse(  );

this.Factory = char( factory );
this.FactoryArgs = opts.FactoryArgs;
this.MappingProperty = char( opts.MappingMetaProperty );
this.BoundObjectKey = char( opts.BoundObjectKey );
this.SubstituteFactory = char( opts.SubstituteFactory );
this.Reuse = opts.Reuse;
this.ExcludeKeys = opts.ExcludeKeys;
this.SyncBoundAsUser = opts.SyncBoundAsUser;
this.SyncBoundWithValidation = opts.SyncBoundWithValidation;
this.SyncBoundObject = opts.SyncBoundObject;
this.Scriptify = opts.Scriptify;
this.ScriptVariable = opts.ScriptVariable;
this.ScriptVariableKey = opts.ScriptVariableKey;

this.ValidateOnImport = false;
end 

function postConstruct( this )
if isempty( this.ExcludeKeys )
this.FilteredKeys = this.ContributorKeys;
else 
this.FilteredKeys = setdiff( this.ContributorKeys, this.ExcludeKeys, 'stable' );
end 

if this.Scriptify
[ keys, props ] = this.keysToProperties(  );
ownProp = this.metadata( this.Key, this.MappingProperty );
if isempty( ownProp )
ownProp = '';
end 
scriptVar = this.ScriptVariable;
if isempty( scriptVar )
if ~isempty( ownProp )
scriptVar = [ lower( ownProp( 1 ) ), ownProp( 2:end  ) ];
else 
scriptVar = [ lower( this.Key( 1 ) ), this.Key( 2:end  ) ];
end 
end 
this.ScriptHelper = coderapp.internal.config.util.CompositeScriptHelper( this.Key, ownProp, scriptVar, [ keys, props ] );
end 
end 

function produce( this )
this.doProduce(  );
end 

function update( this, triggerKeys )
this.doProduce( false, triggerKeys );
end 

function imported = import( this, obj )
if ~isempty( obj ) && ( isobject( obj ) || isstruct( obj ) )
[ mappedKeys, mappedProps ] = this.keysToProperties(  );
resolved = ismember( mappedProps, this.getAccessibleProperties( obj ) );
mappedProps = mappedProps( resolved );
mappedKeys = mappedKeys( resolved );

imported = struct(  );
values = cell( size( mappedKeys ) );
for i = 1:numel( mappedKeys )
values{ i } = obj.( mappedProps{ i } );
imported.( mappedKeys{ i } ) = values{ i };
end 

this.Logger.trace( 'Exploding external value for import onto %s', this.Key );
else 
imported = [  ];
end 
imported = this.postImport( obj, imported );
end 

function set.SyncBoundObject( this, sync )
if this.SyncBoundObject == sync
return 
end 
this.SyncBoundObject = sync;
this.updatePollTimer(  );
end 

function set.SyncPollPeriod( this, period )
this.SyncPollPeriod = max( 1, period );
if ~isempty( this.PollTimer )
this.PollTimer.Period = period;
this.PollTimer.StartDelay = period;
this.updatePollTimer( true );
end 
end 

function mappings = get.AllPropertyMappings( this )
[ keys, props ] = this.keysToProperties(  );
mappings = cell2struct( props, keys, 1 );
end 

function delete( this )
if ~isempty( this.PollingTimer )
this.PollingTimer.stop(  );
this.PollingTimer.delete(  );
this.PollingTimer = [  ];
end 
end 

function resyncBoundObject( this )
logCleanup = this.Logger.debug( 'Resynchronizing bound object "%s"', this.BoundObjectKey );%#ok<NASGU>
if ~isempty( this.BoundObject ) && ( ~isobject( this.BoundObject ) || isvalid( this.BoundObject ) )
try 
this.requestImport( this.BoundObject,  ...
this.SyncBoundAsUser, this.SyncBoundWithValidation );
catch me %#ok<NASGU>
end 
else 
this.BoundObject = [  ];
this.updatePollTimer(  );
end 
end 
end 

methods ( Access = protected )
function instance = instantiate( this )
logCleanup = this.Logger.trace( 'Instantiating new production for "%s"', this.Key );%#ok<NASGU>
if ~isempty( which( this.Factory ) )
instance = feval( this.Factory, this.FactoryArgs{ : } );
scriptUpdate = { this.Factory, this.FactoryArgs };
elseif ~isempty( this.SubstituteFactory )
instance = feval( this.SubstituteFactory );
scriptUpdate = { this.SubstituteFactory };
else 
instance = [  ];
scriptUpdate = { '[]' };
end 
this.Logger.debug( @(  )sprintf( '%s instantiated: class=%s, empty=%g', this.Key, class( instance ), isempty( instance ) ) );
if this.Scriptify
this.ScriptHelper.setInstantiator( scriptUpdate{ : } );
end 
end 

function production = updateProperties( this, production, keys, resetScript )
R36
this
production
keys = this.FilteredKeys
resetScript = true
end 

logCleanup = this.Logger.trace( 'Updating properties/fields on production (%s)', this.Key );%#ok<NASGU>
[ mappedKeys, mappedProps ] = this.keysToProperties( keys );
[ mappedProps, idx ] = intersect( mappedProps, this.getAccessibleProperties( production ), 'stable' );
mappedKeys = mappedKeys( idx );
changed = false;
logger = this.Logger;

if ~isempty( production )
values = this.postProcessValues( mappedKeys, reshape( this.value( mappedKeys ), [  ], 1 ) );
ignoreErrors = this.IgnoreSetterErrors;

for i = 1:numel( mappedProps )
current = production.( mappedProps{ i } );
next = values{ i };
if ( isequal( next, current ) && ~isa( next, 'handle' ) ) || ( isempty( next ) && isempty( current ) )
continue 
end 


if ignoreErrors
try 
production.( mappedProps{ i } ) = next;
catch me
coder.internal.gui.asyncDebugPrint( me );
logger.warn( 'Error applying property/field %s (%s):', mappedProps{ i }, mappedKeys{ i }, me.message );
end 
else 
production.( mappedProps{ i } ) = next;
end 
changed = true;
logger.debug( @(  )sprintf( 'Production property/field "%s" for %s set to: %s',  ...
mappedProps{ i }, mappedKeys{ i }, coderapp.internal.value.valueToExpression( next ) ) );
end 
end 

if changed || ~strcmp( class( production ), class( this.Production ) ) ||  ...
isempty( production ) ~= isempty( this.Production ) ||  ...
( ~isempty( production ) && isa( production, 'handle' ) && production ~= this.Production )
this.Production = production;
end 

if this.Scriptify
if resetScript
[ allMappedKeys, allMappedProps ] = this.keysToProperties( this.FilteredKeys );
this.ScriptHelper.init( [ allMappedKeys, allMappedProps ] );
end 

isParam = this.getDependencyType( mappedKeys ) == "Param";
select = true( size( mappedKeys ) );
select( isParam ) = this.isUserModified( mappedKeys( isParam ) );
code = cell( size( mappedKeys ) );
code( select ) = this.getScriptValues( mappedKeys( select ) );
this.ScriptHelper.updateSnippets( cell2struct( code, mappedKeys, 1 ) );

logger.trace( 'Regenerated production script' );
this.updateScript(  );
this.ScriptHelper.revalidate(  );
this.ScriptModel = this.ScriptHelper.ScriptBuilder;
end 
end 

function [ mappedKeys, mappedProps ] = keysToProperties( this, keys )
if ~iscell( this.KeyToProperty )
allKeys = this.FilteredKeys;
if ~isempty( this.BoundObjectKey )
allKeys = setdiff( allKeys, this.BoundObjectKey, 'stable' );
end 
mappingCues = this.metadata( allKeys, this.MappingProperty );
isMapped = ~cellfun( 'isempty', mappingCues );
mappingCues = mappingCues( isMapped );
mappedKeys = allKeys( isMapped );
this.UnmappedKeys = allKeys( ~isMapped );
if ~isempty( mappedKeys )
this.KeyToProperty = [ reshape( mappedKeys, [  ], 1 ), reshape( mappingCues, [  ], 1 ) ];
else 
this.KeyToProperty = cell( 0, 2 );
end 
end 
if nargin > 1
[ mappedKeys, idx ] = intersect( this.KeyToProperty( :, 1 ), keys, 'stable' );
[ idx, order ] = sort( idx );
mappedKeys = mappedKeys( order );
mappedProps = this.KeyToProperty( idx, 2 );
else 
mappedKeys = this.KeyToProperty( :, 1 );
mappedProps = this.KeyToProperty( :, 2 );
end 
end 

function propNames = getAccessibleProperties( ~, obj )
persistent propMap;
if isempty( propMap )
propMap = containers.Map(  );
end 
if isstruct( obj )
propNames = fieldnames( obj );
return 
end 
className = class( obj );
if propMap.isKey( className )
propNames = propMap( className );
else 
props = metaclass( obj ).PropertyList;
propNames = { props( { props.SetAccess } == "public" & { props.GetAccess } == "public" ).Name };
propMap( className ) = propNames;
end 
end 

function values = postProcessValues( this, keys, values )%#ok<INUSL>
end 

function reuse = canReuse( ~ )
reuse = true;
end 

function imported = postImport( ~, ~, imported )
end 

function updateScript( ~ )
end 
end 

methods ( Access = private )
function doProduce( this, fromScratch, triggerKeys )
R36
this
fromScratch = true
triggerKeys = {  }
end 

if ~isempty( this.BoundObjectKey )
boundObj = this.value( this.BoundObjectKey );
boundChange = fromScratch || ismember( this.BoundObjectKey, triggerKeys );
else 
boundObj = [  ];
boundChange = false;
end 
this.BoundObject = boundObj;

rebaseline = false;
shouldImport = false;
instance = this.Production;
if isempty( boundObj )
if fromScratch || boundChange || isempty( instance ) || ~this.Reuse || ~this.canReuse(  )
instance = this.instantiate(  );
rebaseline = true;
updateKeys = this.FilteredKeys;
else 
instance = this.Production;
updateKeys = triggerKeys;
end 
else 
instance = boundObj;
shouldImport = boundChange && ~this.Importing;
rebaseline = boundChange;
if fromScratch
updateKeys = this.FilteredKeys;
else 
updateKeys = setdiff( triggerKeys, this.BoundObjectKey, 'stable' );
end 
end 

this.updateProperties( instance, updateKeys, rebaseline );
if shouldImport
this.resyncBoundObject(  );
this.Production = instance;
elseif fromScratch
this.Production = instance;
end 
this.updatePollTimer( this.Importing );
end 

function updatePollTimer( this, restart )
R36
this
restart = false
end 

if this.SyncBoundObject && ~isempty( this.BoundObject )
if isempty( this.PollingTimer )
this.PollingTimer = timer(  ...
'ExecutionMode', 'fixedSpacing',  ...
'ObjectVisibility', 'off',  ...
'Period', this.SyncPollPeriod,  ...
'StartDelay', this.SyncPollPeriod,  ...
'TimerFcn', @( ~, ~ )this.resyncBoundObject(  ),  ...
'Tag', sprintf( 'CompositeProducerPoll[%s]', this.BoundObjectKey ) );
end 
if strcmp( this.PollingTimer.Running, 'off' )
this.PollingTimer.start(  );
elseif restart
this.PollingTimer.stop(  );
this.PollingTimer.start(  );
end 
elseif ~isempty( this.PollingTimer ) && ( ~this.SyncBoundObject || isempty( this.BoundObject ) )
this.PollingTimer.stop(  );
end 
end 
end 
end 
% Decoded using De-pcode utility v1.2 from file /tmp/tmpFFuW0u.p.
% Please follow local copyright laws when handling this file.

