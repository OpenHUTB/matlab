classdef ( Sealed )Lock < handle





properties ( Transient )
Locked( 1, 1 )logical = false
end 

properties ( Dependent )
Model
end 

properties ( Access = private )
ModelContexts = struct( 'model', {  }, 'lock', {  }, 'listener', {  } )
end 

properties ( GetAccess = private, SetAccess = immutable, Transient )
InternalModel mf.zero.Model
end 

methods 
function this = Lock( models, opts )
R36
models = [  ]
opts.Locked( 1, 1 ){ mustBeNumericOrLogical( opts.Locked ) } = false
end 
this.Locked = opts.Locked;
this.InternalModel = mf.zero.Model(  );
this.Model = models;
end 
end 

methods 
function set.Locked( this, locked )
if locked ~= this.Locked
this.Locked = locked;
this.updateLocks(  );
end 
end 

function set.Model( this, models )
if ~isempty( models ) && ~isa( models, 'mf.zero.Model' )
error( 'Model must be an array of MF0 models or empty' );
end 
for i = 1:numel( this.ModelContexts )
this.unmanage( this.ModelContexts( i ) );
end 
models = unique( models );
contexts = cell( numel( models ), 3 );
for i = 1:numel( models )
contexts( i, : ) = { 
models( i )
coderapp.internal.util.ModelLock( this.InternalModel )
listener( models( i ), 'ObjectBeingDestroyed',  ...
@( model, ~ )this.onModelDestroyed( model ) )
 };
end 
this.ModelContexts = cell2struct( contexts, { 'model', 'lock', 'listener' }, 2 );
this.updateLocks(  );
end 

function models = get.Model( this )
if ~isempty( this.ModelContexts )
models = [ this.ModelContexts.model ];
else 
models = mf.zero.Model.empty(  );
end 
end 
end 

methods ( Access = private )
function updateLocks( this )
locked = this.Locked;
for i = 1:numel( this.ModelContexts )
context = this.ModelContexts( i );
if locked
context.lock.lock( context.model );
else 
context.lock.unlock(  );
end 
end 
end 

function onModelDestroyed( this, model )
idx = find( [ this.ModelContexts.model ] == model );
this.unmanage( this.ModelContexts( idx ) );
this.ModelContexts( idx ) = [  ];
end 
end 

methods ( Static, Access = private )
function unmanage( modelContext )
modelContext.lock.destroy(  );
modelContext.listener = [  ];
end 
end 
end 
% Decoded using De-pcode utility v1.2 from file /tmp/tmpnfJ9H0.p.
% Please follow local copyright laws when handling this file.

