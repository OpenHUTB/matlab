function cList = addComponent( this, componentNames, stereotype, creationOptions )



















R36
this{ mustBeA( this, 'systemcomposer.arch.Architecture' ) }
componentNames{ mustBeText }
stereotype{ mustBeText } = ""
creationOptions.Position{ mustBeNumeric, mustBeVector }
creationOptions.Type{ mustBeA( creationOptions.Type, 'systemcomposer.ArchitectureType' ) } = systemcomposer.ArchitectureType.empty( 0, 1 );
creationOptions.IsReusable{ mustBeNumericOrLogical } = false
creationOptions.FileName{ mustBeTextScalar } = ""
creationOptions.Template{ mustBeTextScalar } = ""
creationOptions.Reference{ mustBeTextScalar } = ""
end 

this.validateAPISupportForAUTOSAR( 'addComponent' );

creationOptions.FileName = string( creationOptions.FileName );
creationOptions.Template = string( creationOptions.Template );
creationOptions.Reference = string( creationOptions.Reference );


if isempty( creationOptions.Type )
if Simulink.internal.isArchitectureModel( this.SimulinkModelHandle, 'SoftwareArchitecture' )
creationOptions.Type = systemcomposer.ArchitectureType.SoftwareArchitecture;
else 
creationOptions.Type = systemcomposer.ArchitectureType.Architecture;
end 
end 

stereotype = string( stereotype );
componentNames = string( componentNames );

if ~isempty( stereotype ) && length( stereotype ) > 1
if ~isequal( length( stereotype ), length( componentNames ) )
error( 'systemcomposer:API:AddComponentStereotypeMismatch', message(  ...
'SystemArchitecture:API:AddComponentStereotypeMismatch' ).getString );
end 
end 



if length( stereotype ) == 1
stereotype = repmat( stereotype, 1, length( componentNames ) );
end 

compPos = [  ];
if isfield( creationOptions, 'Position' )
compPos = creationOptions.Position;
end 


if ~isempty( compPos )
[ posM, posN ] = size( compPos );
if length( componentNames ) ~= posM || posN ~= 4
error( 'systemcomposer:API:ComponentPositionsInvalid', message(  ...
'SystemArchitecture:API:ComponentPositionsInvalid' ).getString );
end 
end 




doPreCreationChecks( this, creationOptions );



if isequal( creationOptions.Type, systemcomposer.ArchitectureType.SimulinkModel ) && ~creationOptions.IsReusable
error( 'systemcomposer:API:AddComponentModelLinkInvalidFlag', message(  ...
'SystemArchitecture:API:AddComponentModelLinkInvalidFlag' ).getString );
end 


if creationOptions.IsReusable && ( creationOptions.FileName.matches( "" ) && creationOptions.Reference.matches( "" ) )
error( 'systemcomposer:API:AddComponentMissingModelInformation', message(  ...
'SystemArchitecture:API:AddComponentMissingModelInformation' ).getString );
end 

if ~creationOptions.FileName.matches( "" ) && ~creationOptions.Reference.matches( "" )
error( 'systemcomposer:API:AddComponentConflictingModelInformation', message(  ...
'SystemArchitecture:API:AddComponentConflictingModelInformation' ).getString );
end 

if ~creationOptions.Reference.matches( "" ) && ~creationOptions.IsReusable
error( 'systemcomposer:API:AddComponentModelLinkInvalidFlag', message(  ...
'SystemArchitecture:API:AddComponentModelLinkInvalidFlag' ).getString )
end 



[ sortedCompNames, sortIdxs ] = sort( componentNames );




sortedCompsToAdd = systemcomposer.internal.arch.internal.calculateMissingLayers( this.Model,  ...
this.getQualifiedName, sortedCompNames );


t = this.MFModel.beginTransaction;
bhs = cell( 1, length( sortedCompNames ) );
idx = 0;
mdlH = this.SimulinkModelHandle;
for k = 1:length( sortedCompsToAdd )
thisCompName = sortedCompsToAdd( k );
blkPath = string( this.getQualifiedName ).append( "/" ).append( thisCompName );

try 
bh = add_block( 'built-in/Subsystem', blkPath,  ...
'TreatAsAtomicUnit', 'off' );
if ( ismember( thisCompName, sortedCompNames ) )
idx = idx + 1;
originalIdx = sortIdxs( idx );
bhs( originalIdx ) = { bh };
end 
catch 

systemcomposer.internal.arch.internal.processBatchedPluginEvents( mdlH );
t.commit;
error( 'systemcomposer:API:ComponentExists', message(  ...
'SystemArchitecture:API:ComponentExists', thisCompName ).getString );
end 
end 

systemcomposer.internal.arch.internal.processBatchedPluginEvents( mdlH );

cImplList = cell( 1, length( sortedCompNames ) );
for idx = 1:numel( bhs )
bh = bhs( idx );
cImplList{ idx } = systemcomposer.utils.getArchitecturePeer( bh{ : } );
if ~isempty( compPos )
set_param( bh{ : }, 'Position', compPos( idx, : ) );
end 
end 


t.commit;


cList = cell( 1, length( cImplList ) );
t = this.MFModel.beginTransaction;
for i = 1:numel( cImplList )
cList{ i } = systemcomposer.internal.getWrapperForImpl( cImplList{ i }, 'systemcomposer.arch.Component' );
switch ( creationOptions.Type )
case systemcomposer.ArchitectureType.Architecture
if creationOptions.IsReusable && ~creationOptions.FileName.matches( "" )
cList{ i }.createArchitectureModel( creationOptions.FileName, creationOptions.Type.char, 'Template', creationOptions.Template );
end 
if creationOptions.IsReusable && ~creationOptions.Reference.matches( "" )
cList{ i }.linkToModel( creationOptions.Reference );
end 
case systemcomposer.ArchitectureType.SoftwareArchitecture
if creationOptions.IsReusable && ~creationOptions.FileName.matches( "" )
cList{ i }.createArchitectureModel( creationOptions.FileName, creationOptions.Type.char, 'Template', creationOptions.Template );
end 
if creationOptions.IsReusable && ~creationOptions.Reference.matches( "" )
cList{ i }.linkToModel( creationOptions.Reference );
end 
otherwise 
pvPairs = namedargs2cell( creationOptions );
cList{ i }.createBehavior( pvPairs{ : } );
end 
end 
t.commit;
cList = [ cList{ : } ];


t = this.MFModel.beginTransaction;
for k = 1:length( cImplList )
if ~stereotype.matches( "" )
systemcomposer.internal.arch.applyPrototype( cImplList{ k }, stereotype( k ) );
end 
end 
t.commit;

end 

function doPreCreationChecks( archObj, creationOptions )




if Simulink.internal.isArchitectureModel( archObj.SimulinkModelHandle, 'SoftwareArchitecture' ) &&  ...
~( isequal( creationOptions.Type, systemcomposer.ArchitectureType.SoftwareArchitecture ) ||  ...
isequal( creationOptions.Type, systemcomposer.ArchitectureType.SimulinkModel ) )
error( 'systemcomposer:API:AddComponentInvalidTypeForArchitecture', message(  ...
'SystemArchitecture:API:AddComponentInvalidTypeForArchitecture', creationOptions.Type.char, 'SoftwareArchitecture' ).getString );
end 

switch ( creationOptions.Type )
case systemcomposer.ArchitectureType.Architecture

case systemcomposer.ArchitectureType.SoftwareArchitecture



if Simulink.internal.isArchitectureModel( archObj.SimulinkModelHandle, 'Architecture' ) && ~creationOptions.IsReusable
error( 'systemcomposer:API:AddComponentSWTypeInvalidConfigurationForArchitecture', message(  ...
'SystemArchitecture:API:AddComponentSWTypeInvalidConfigurationForArchitecture' ).getString );
end 
case systemcomposer.ArchitectureType.SimulinkModel

case systemcomposer.ArchitectureType.SimulinkSubsystem
if ~slfeature( 'ZCInlineSubsystem' ) && ~creationOptions.IsReusable
error( 'systemcomposer:API:AddComponentCannotCreateInlinedSimulink', message(  ...
'SystemArchitecture:API:AddComponentCannotCreateInlinedSimulink' ).getString );
end 
if ~slfeature( 'ZCSubsystemReference' ) && ( creationOptions.IsReusable || ~creationOptions.Reference.matches( "" ) )
error( 'systemcomposer:API:AddComponentCannotCreateSSRef', message(  ...
'SystemArchitecture:API:AddComponentCannotCreateSSRef' ).getString );
end 
case systemcomposer.ArchitectureType.Stateflow
if ~dig.isProductInstalled( 'Stateflow' )
msgObj = message( 'SystemArchitecture:API:StateflowLicenseError' );
exception = MException( 'systemcomposer:API:StateflowLicenseError',  ...
msgObj.getString );
throw( exception );
end 
if creationOptions.IsReusable || ~creationOptions.Reference.matches( "" )
error( 'systemcomposer:API:AddComponentStateflowCannotBeReusable', message(  ...
'SystemArchitecture:API:AddComponentStateflowCannotBeReusable' ).getString );
end 
end 

end 

% Decoded using De-pcode utility v1.2 from file /tmp/tmpXHGZ8k.p.
% Please follow local copyright laws when handling this file.

