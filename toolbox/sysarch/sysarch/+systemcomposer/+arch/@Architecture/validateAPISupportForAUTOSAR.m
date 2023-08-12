function validateAPISupportForAUTOSAR( this, fcnName )




R36
this{ mustBeA( this, 'systemcomposer.arch.Architecture' ) }
fcnName{ mustBeText }
end 
unsupportedFcnsForComposition = { 'addFunction', 'addVariantComponent' };
supportedFcnsForApplicationComp = { 'addPort', 'addFunction' };

if Simulink.internal.isArchitectureModel( bdroot( this.SimulinkHandle ), 'AUTOSARArchitecture' )
if autosar.composition.Utils.isCompositionBlock( this.SimulinkHandle )

if any( strcmp( fcnName, unsupportedFcnsForComposition ) )
ex = getUnsupportedAPIMException( this.SimulinkHandle );
ex.throwAsCaller(  );
end 
else 
if isempty( this.Parent ) && isempty( get_param( this.SimulinkHandle, 'Parent' ) )

if any( strcmp( fcnName, unsupportedFcnsForComposition ) )
ex = getUnsupportedAPIMException( this.SimulinkHandle );
ex.throwAsCaller(  );
end 
else 

isServiceComponent = this.Parent.getImpl.isServiceComponent;
if isServiceComponent || ( ~isServiceComponent && ~any( strcmp( fcnName, supportedFcnsForApplicationComp ) ) )
parentName = getfullname( this.Parent.SimulinkHandle );
msgObj = message( 'autosarstandard:api:CanOnlyAddComponentsInComposition', parentName );
exception = MException( 'autosarstandard:api:CanOnlyAddComponentsInComposition',  ...
msgObj.getString );
exception.throwAsCaller(  );
end 
end 
end 
end 
end 

function exception = getUnsupportedAPIMException( blkHdl )
subdomain = get_param( blkHdl, 'SimulinkSubDomain' );
if strcmp( subdomain, 'AUTOSARArchitecture' )
modelName = get_param( bdroot( blkHdl ), 'Name' );
msgObj = message( 'SystemArchitecture:API:AUTOSARModelNotSupported', modelName );
exception = MException( 'systemcomposer:API:AUTOSARModelNotSupported',  ...
msgObj.getString );
end 
end 
% Decoded using De-pcode utility v1.2 from file /tmp/tmpyLtHXm.p.
% Please follow local copyright laws when handling this file.

