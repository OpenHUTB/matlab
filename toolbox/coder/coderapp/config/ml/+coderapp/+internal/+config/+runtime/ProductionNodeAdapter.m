classdef ( Sealed )ProductionNodeAdapter < coderapp.internal.config.runtime.ReferableNodeAdapter



properties ( Constant )
NodeType coderapp.internal.config.runtime.NodeType = coderapp.internal.config.runtime.NodeType.Production
end 

properties ( Access = private, Constant )
IDLE = 0
UPDATING = 1
IMPORTING = 2
end 

properties ( SetAccess = private )
Dependencies coderapp.internal.config.runtime.ReferableNodeAdapter
end 

properties ( SetAccess = private )
NodeActive logical = false
end 

properties ( SetAccess = protected )
Dirty logical
end 

properties ( Dependent, Hidden, SetAccess = immutable )
ReferableValue
ExportedValue
ScriptValue
ScriptCode
end 

properties ( GetAccess = private, SetAccess = immutable )
State coderapp.internal.config.runtime.ProductionState
end 

properties ( Dependent, SetAccess = ?coderapp.internal.config.Configuration )
ApplyingImport
end 

properties ( SetAccess = { ?coderapp.internal.config.runtime.ProductionNodeAdapter,  ...
?coderapp.internal.config.Configuration } )
TrackScriptDeltas( 1, 1 )logical
end 

properties ( GetAccess = ?coderapp.internal.config.Configuration, SetAccess = private )
Producer coderapp.internal.config.AbstractProducer
end 

properties ( Access = private, Transient )
Production
ScriptBuilder coderapp.internal.script.ScriptBuilder
UpdateState double = coderapp.internal.config.runtime.ProductionNodeAdapter.IDLE
end 

methods 
function this = ProductionNodeAdapter( prodDef, schemaIdx, trackScriptDeltas )
R36
prodDef coderapp.internal.config.schema.ProductionDef
schemaIdx
trackScriptDeltas( 1, 1 )logical = false
end 

this@coderapp.internal.config.runtime.ReferableNodeAdapter( prodDef, schemaIdx );
this.MetadataMap = prodDef.InitialState.Metadata;
this.TrackScriptDeltas = trackScriptDeltas;
this.State = prodDef.InitialState;
end 

function production = get.ReferableValue( this )
production = this.Production;
end 

function production = get.ExportedValue( this )
production = this.ReferableValue;
end 

function scriptValue = get.ScriptValue( this )
scriptValue = this.ScriptBuilder;
end 

function code = get.ScriptCode( this )
code = this.State.Script;
if ~isempty( code )
code = code.Code;
else 
code = '';
end 
end 

function imported = import( this, externalValue )
logCleanup = this.Logger.trace( 'Processing production import for "%s"', this.Key );%#ok<NASGU>
cleanup = this.setUpdateState( this.UPDATING );%#ok<NASGU>
imported = this.Producer.import( externalValue );
cleanup = [  ];%#ok<NASGU>            
if ~isempty( imported ) && ( ~isa( imported, 'struct' ) || ~isscalar( imported ) )
error( 'Producer import method should return a scalar struct' );
end 
end 

function dirty = get.Dirty( ~ )
dirty = false;
end 

function set.Production( this, production )
if ~isempty( production ) && ~isempty( this.SchemaDef.AllowedClasses )
mustBeA( production, this.SchemaDef.AllowedClasses );
end 
this.Production = production;
if this.Configuration.MfzExposeProductions
this.SchemaDef.InitialState.Production = production;
end 
end 

function importing = get.ApplyingImport( this )
importing = ~isempty( this.Producer ) && this.Producer.Importing;
end 

function set.ApplyingImport( this, importing )
this.Producer.Importing = importing;
end 

function delete( this )
if isempty( this.Producer ) || ~isvalid( this.Producer )
return 
end 
this.Producer.Node = coderapp.internal.config.runtime.ProductionNodeAdapter.empty(  );
this.Producer.delete(  );
end 
end 

methods ( Access = { ?coderapp.internal.config.runtime.NodeAdapter, ?coderapp.internal.config.Configuration,  ...
?coderapp.internal.config.runtime.ConfigStoreAdapter } )
function initNode( this, configuration )
initNode@coderapp.internal.config.runtime.ReferableNodeAdapter( this, configuration );
if ~isempty( this.SchemaDef.Contributors )
this.Dependencies = configuration.getNodes( [ this.SchemaDef.Contributors.Ordinal ] );
end 
end 

function activateNode( this )
if this.NodeActive
return 
end 
logCleanup = this.Logger.trace( 'Initializing production "%s"', this.Key );%#ok<NASGU>
this.Producer = feval( this.SchemaDef.ProducerClass, this.SchemaDef.ConstructorArgs{ : } );
this.Producer.Key = this.Key;
this.Producer.ContributorKeys = { this.Dependencies.Key };
this.Producer.Node = this;
this.Producer.postConstruct(  );
this.NodeActive = true;
this.reset(  );
end 

function updateNode( this, triggers )
R36
this
triggers coderapp.internal.config.runtime.ReferableNodeAdapter
end 

logCleanup = this.Logger.trace( 'Invoking producer update for "%s"', this.Key );%#ok<NASGU>
cleanup = this.setUpdateState( this.UPDATING );%#ok<NASGU>            
this.Producer.update( { triggers.Key } );
end 

function modified = reset( this )
logCleanup = this.Logger.trace( 'Resetting production "%s"', this.Key );%#ok<NASGU>
cleanup = this.setUpdateState( this.UPDATING );%#ok<NASGU>
this.Producer.produce(  );
modified = this.Propagate;
end 
end 

methods ( Access = ?coderapp.internal.config.AbstractProducer )
function updateProduction( this, production )
logCleanup = this.Logger.trace( 'Updating production "%s"', this.Key );%#ok<NASGU>
if this.UpdateState == this.IMPORTING
error( 'Cannot update production during import' );
end 
this.Production = production;
if ~isempty( production )
this.State.ProductionClass = class( production );
else 
this.State.ProductionClass = '';
end 
this.Logger.debug( @(  )sprintf( 'Production value set to: %s %s',  ...
strjoin( string( size( production ) ), 'x' ), this.State.ProductionClass ) );
switch this.UpdateState
case this.UPDATING
this.Propagate = true;
otherwise 
this.Configuration.assertNotPropagating(  );
this.Configuration.internalUpdate( this );
end 
this.updateSuccessorDepViews(  );
this.Configuration.reportChange( this );
end 

function updateScript( this, script )
logCleanup = this.Logger.trace( 'Updating script for "%s"', this.Key );%#ok<NASGU>
if ~isempty( this.State.ScriptDelta )
this.State.ScriptDelta.destroy(  );
end 

scriptOptions = this.Configuration.ScriptOptions;
if isa( script, 'coderapp.internal.script.ScriptBuilder' )
this.ScriptBuilder = script;
next = script.build( scriptOptions );
else 
if isempty( script )
script = '';
this.ScriptBuilder = coderapp.internal.script.ScriptBuilder.empty(  );
else 
this.ScriptBuilder = coderapp.internal.script.ScriptBuilder( script );
end 
next = coderapp.internal.script.AnnotatedScript( this.Configuration.RuntimeModel,  ...
struct( 'Code', script ) );
end 

prev = this.State.Script;
if ~isempty( prev )
prevCode = prev.Code;
if strcmp( prev.Code, next.Code ) && isequal( prev.Annotations, next.Annotations )
next.destroy(  );
return 
else 
prev.destroy(  );
end 
else 
prevCode = '';
end 

if this.TrackScriptDeltas
delta = coderapp.internal.script.TextDelta( this.Configuration.RuntimeModel );
if ~strcmp( prevCode, next.Code )
populateTextDelta( delta, prevCode, next.Code, scriptOptions.ZeroBased );
end 
this.State.ScriptDelta = delta;
end 

this.State.Script = next;
end 

function deferredImportRequested( this, value, asUser, validateValues )
if this.UpdateState == this.IMPORTING || this.ApplyingImport
error( 'Cannot request an import while already performing an import' );
end 
this.Configuration.deferredImport( this, value, AsUser = asUser, Validate = validateValues );
end 
end 

methods ( Access = private )
function cleanup = setUpdateState( this, state )
R36
this
state double = this.IDLE
end 

this.UpdateState = state;
cleanup = [  ];
end 

function clearUpdateState( this )
this.UpdateState = this.IDLE;
this.Producer.detachFromNode(  );
end 
end 
end 


function populateTextDelta( deltaObj, old, new, zeroBased )
[ oldAlign, newAlign ] = codergui.internal.util.alignMatlabCode( old, new, 'IgnoreLiteralValues', false );
ocTree = oldAlign.setIX( ~oldAlign.getIX(  ) );
deltaObj.Deletes = pairsToRanges( [ ocTree.lefttreepos(  ), ocTree.righttreepos(  ) ], zeroBased );
ncTree = newAlign.setIX( ~newAlign.getIX(  ) );
deltaObj.Adds = pairsToRanges( [ ncTree.lefttreepos(  ), ncTree.righttreepos(  ) ], zeroBased );
end 


function ranges = pairsToRanges( pairs, zeroBased )
ranges = repmat( coderapp.internal.util.Range, 1, size( pairs, 1 ) );
for i = 1:numel( ranges )
ranges( i ).Start = pairs( i, 1 ) - zeroBased;
ranges( i ).End = pairs( i, 2 );
end 
end 
% Decoded using De-pcode utility v1.2 from file /tmp/tmpM5FCPi.p.
% Please follow local copyright laws when handling this file.

