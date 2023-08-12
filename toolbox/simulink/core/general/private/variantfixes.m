function action_performed = variantfixes( aMsgId, varargin )




fix_function = [ 'fix', aMsgId ];
action_performed = feval( fix_function, varargin );
end 



function action_performed = fixVariantChildSubsystemMustBeAtomic( varargin )
aParentSubsysPath = varargin{ 1 }{ 1 };

child_subsys = get_param( aParentSubsysPath, 'Variants' );
for index = 1:length( child_subsys )
try %#ok<TRYNC>

child_subsys( index ).atomicState = get_param( child_subsys( index ).BlockName, 'TreatAsAtomicUnit' );
end 
end 


try 

action_performed = [ message( 'Simulink:Engine:VariantChildSubsystemMustBeAtomic_Fix' ).getString(  ), ' ' ];
for fix_index = 1:length( child_subsys )
if ( ~isempty( child_subsys( fix_index ).atomicState ) )
if ( ~strcmp( get_param( child_subsys( fix_index ).BlockName, 'TreatAsAtomicUnit' ), 'on' ) )

set_param( child_subsys( fix_index ).BlockName, 'TreatAsAtomicUnit', 'on' );
action_performed = [ action_performed, child_subsys( fix_index ).BlockName, ', ' ];
end 
end 
end 

action_performed( length( action_performed ) - 1 ) = '.';
catch error

for revert_index = 1:length( child_subsys )
try %#ok<TRYNC>

set_param( child_subsys( revert_index ).BlockName, 'TreatAsAtomicUnit', child_subsys( revert_index ).atomicState );
end 
end 

rethrow( error );
end 
end 





function action_performed = fixInlineVariantExtOutputNotSupported( varargin )
mode = varargin{ 1 }{ 1 };
numExtOutports = varargin{ 1 }{ 2 };

currOutSaveName = get_param( bdroot, 'OutputSaveName' );

currOutSaveNameOnPort = strsplit( currOutSaveName, ',' );

numOutputSaveNames = length( currOutSaveNameOnPort );

newOutVarName = { 'yout' };


newOutVarName = repmat( newOutVarName, 1, numExtOutports - numOutputSaveNames );



portNumbers = num2cell( numOutputSaveNames + 1:numExtOutports );


newOutVarName = cellfun( @( x, idx )[ x, num2str( idx ) ], newOutVarName, portNumbers, 'UniformOutput', false );

newOutputSaveName = [ currOutSaveNameOnPort, newOutVarName ];


newOutputSaveName = matlab.lang.makeUniqueStrings( newOutputSaveName );


if ( isempty( setdiff( newOutputSaveName, currOutSaveNameOnPort ) ) )





newOutputSaveName = currOutSaveNameOnPort( 1:numExtOutports );
end 
newOutputSaveName = strjoin( newOutputSaveName, ',' );


if ( strcmp( mode, 'specify_csv_list' ) )
set_param( bdroot, 'OutputSaveName', newOutputSaveName );
if ( ~strcmp( get_param( bdroot, 'SaveFormat' ), 'Dataset' ) )
action_performed = message( 'Simulink:Variants:InlineVariantExtOutputNotSupportedFixCSVList' ).getString(  );
end 
end 
end 



function action_performed = fixInlineVariantZeroVariantsNotAllowed( varargin )
mode = varargin{ 1 }{ 1 };
block = varargin{ 1 }{ 2 };

if ( strcmp( mode, 'enable_azvc' ) )
set_param( block, 'AllowZeroVariantControls', 'on' );
action_performed = message( 'Simulink:Variants:InlineVariantZeroVariantsNotAllowedFixAZVC' ).getString(  );
end 
end 


function action_performed = fixVSSPropagateConditions( varargin )
vssBlock = varargin{ 1 }{ 1 };

set_param( vssBlock, 'PropagateVariantConditions', 'on' );
action_performed = [ message( 'Simulink:Variants:VarCondPropUnsupportedVSSBlockErr_fix' ).getString(  ), ' ', vssBlock ];
end 







function action_performed = fixCodeVariantConfigExternalMode( varargin )
bdname = varargin{ 1 }{ 1 };
vss = find_system( bdname, 'FollowLinks', 'on', 'LookUnderMasks', 'all',  ...
'MatchFilter', @Simulink.match.allVariants, 'BlockType', 'SubSystem', 'Variant', 'on' );
for i = 1:size( vss, 1 )
set_param( vss{ i }, 'GeneratePreprocessorConditionals', 'off' );
end 
action_performed = [ message( 'Simulink:Variants:CodeVariantConfigExternalMode_fix' ).getString(  ) ];
end 

function action_performed = fixLogicalModeledAsBitwiseError( varargin )
bdname = varargin{ 1 }{ 1 };
set_param( bdname, 'BitwiseOrLogicalOp', 'Logical operator' );
action_performed = [ message( 'Simulink:Variants:LogicalModeledAsBitwiseError_fix' ).getString(  ) ];
end 




function action_performed = fixCodeVariantCustomStorageClassesIgnored( varargin )
bdname = varargin{ 1 }{ 1 };
set_param( bdname, 'IgnoreCustomStorageClasses', 'off' );
action_performed = [ message( 'Simulink:Variants:CodeVariantCustomStorageClassesIgnored_fix' ).getString(  ) ];
end 




function action_performed = fixConvertNormalVarControlToSimulinkParam( varargin )
varName = varargin{ 1 }{ 1 };
modelName = bdroot;
varValue = evalinGlobalScope( modelName, varName );
evalinGlobalScope( modelName, [ varName, '= Simulink.Parameter;' ] );
evalinGlobalScope( modelName, [ varName, '.Value = ', 'int32(', num2str( varValue ), ');' ] );
evalinGlobalScope( modelName, [ varName, '.CoderInfo.StorageClass =  ''Custom'' ;' ] )
evalinGlobalScope( modelName, [ varName, '.CoderInfo.CustomStorageClass = ''CompilerFlag'' ;' ] )


buildConfiguration = get_param( bdroot, 'BuildConfiguration' );
ctrlVarsCompilerFlags = [ '-D', varName, '=', num2str( varValue ), ' ' ];
if strcmpi( buildConfiguration, 'specify' )
opts = get_param( modelName, 'CustomToolchainOptions' );
idx = find( strcmpi( 'C Compiler', opts ) );
idx = idx + 1;
cCompilerValCurrent = opts{ idx };
opts{ idx } = strcat( cCompilerValCurrent, ctrlVarsCompilerFlags );
set_param( modelName, 'CustomToolchainOptions', opts );
end 
existingMakeCmdVal = get_param( modelName, 'MakeCommand' );
makeCmd = [ existingMakeCmdVal, ' OPTS="', ctrlVarsCompilerFlags, '"' ];
set_param( modelName, 'MakeCommand', makeCmd );
action_performed = message( 'Simulink:Variants:NonSimulinkParamConflictWithVarControl_fix', varName ).getString(  );
end 



function action_performed = fixConvertNormalVarControlToSimulinkParamForSt( varargin )
varName = varargin{ 1 }{ 1 };
modelName = varargin{ 1 }{ 2 };
varValue = evalinGlobalScope( varargin{ 1 }{ 2 }, varargin{ 1 }{ 1 } );
if ( ~isa( varValue, 'Simulink.Parameter' ) )
evalinGlobalScope( modelName, [ varName, '= Simulink.Parameter;' ] );
evalinGlobalScope( modelName, [ varName, '.Value = ', 'int32(', num2str( varValue ), ');' ] );
evalinGlobalScope( modelName, [ varName, '.CoderInfo.StorageClass =  ''ExportedGlobal'' ;' ] )
end 
action_performed = message( 'Simulink:Variants:NonSimulinkParamNotSupportedForStartup_fix', varName ).getString(  );
end 





function rePositionBlockInBetween( leftBlk, middleBlk, rightBlk )
leftBlkPos = get_param( leftBlk, 'Position' );
rightBlkPos = get_param( rightBlk, 'Position' );


curMiddleBlkPos = get_param( middleBlk, 'Position' );
middleBlkHeight = curMiddleBlkPos( 4 ) - curMiddleBlkPos( 2 );
middleBlkWidth = curMiddleBlkPos( 3 ) - curMiddleBlkPos( 1 );


axialDisBetBlocks = leftBlkPos( 3 ) - rightBlkPos( 1 );
if ( axialDisBetBlocks < middleBlkWidth )
rightBlockType = get_param( rightBlk, 'BlockType' );
if ( rightBlockType == 'Outport' )
newRightBlockPos = [ rightBlkPos( 1 ) + 1.5 * middleBlkWidth, rightBlkPos( 2 ), rightBlkPos( 3 ) + 1.5 * middleBlkWidth, rightBlkPos( 4 ) ];
set_param( rightBlk, 'Position', newRightBlockPos );
rightBlkPos = newRightBlockPos;
end 
end 


xCenter = ( leftBlkPos( 3 ) + rightBlkPos( 1 ) ) / 2;
yCenter = ( leftBlkPos( 2 ) + leftBlkPos( 4 ) ) / 2;


middlePos = [ xCenter - middleBlkWidth / 2, yCenter - middleBlkHeight / 2, xCenter + middleBlkWidth / 2, yCenter + middleBlkHeight / 2 ];
set_param( middleBlk, 'Position', middlePos );
end 




function action_performed = fixInsertSignalConversionBlk( varargin )

















outBlkPath = varargin{ 1 }{ 1 };
outBlkHandle = get_param( outBlkPath, 'Handle' );
outBlkPortConnectivity = get_param( outBlkHandle, 'PortConnectivity' );
muxBlkHandle = outBlkPortConnectivity.SrcBlock;
srcPort = outBlkPortConnectivity.SrcPort;




outBlkLineHndl = get_param( outBlkHandle, 'LineHandles' );
orgLinetHndl = outBlkLineHndl.Inport;
delete_line( orgLinetHndl );


outBlkPortHndl = get_param( outBlkHandle, 'PortHandles' );
outBlkLeftHndl = outBlkPortHndl.Inport;


muxPortHndl = get_param( muxBlkHandle, 'PortHandles' );
muxRgtPortHndl = muxPortHndl.Outport;



sigConvBlkParent = get_param( outBlkHandle, 'Parent' );
sigConvBlkPath = [ sigConvBlkParent, '/signal Conversion' ];


sigConvBlkHandle = add_block( 'simulink/Signal Attributes/Signal Conversion', sigConvBlkPath, 'MakeNameUnique', 'on' );

rePositionBlockInBetween( muxBlkHandle, sigConvBlkHandle, outBlkHandle );


sigConvBlkLineHndl = get_param( sigConvBlkHandle, 'PortHandles' );
sigConvBlkLeftPortHndl = sigConvBlkLineHndl.Inport;
sigConvBlkRgtPortHndl = sigConvBlkLineHndl.Outport;


add_line( sigConvBlkParent, muxRgtPortHndl( srcPort + 1 ), sigConvBlkLeftPortHndl, 'autorouting', 'on' );
add_line( sigConvBlkParent, sigConvBlkRgtPortHndl, outBlkLeftHndl, 'autorouting', 'on' );

action_performed = [ message( 'Simulink:blocks:InvVariantMergeUsage_fix' ).getString(  ) ];

end 




function action_performed = fixVariantSubsystemInitialValueOnGround( varargin )
outBlkName = varargin{ 1 }{ 1 };

try 

if ( ~strcmp( get_param( outBlkName, 'OutputWhenUnconnected' ), 'on' ) )

set_param( outBlkName, 'OutputWhenUnconnected', 'on' );
end 
action_performed = [ message( 'Simulink:Signals:SigobjInitialValueOnGroundVSS_fix' ).getString(  ) ];
catch error

rethrow( error );
end 
end 




function action_performed = fixVariantSubsystemEnableAZVC( varargin )
inactiveBlkName = varargin{ 1 }{ 1 };

try 
if ( ~strcmp( get_param( inactiveBlkName, 'AllowZeroVariantControls' ), 'on' ) )

set_param( inactiveBlkName, 'AllowZeroVariantControls', 'on' );
action_performed = [ message( 'Simulink:blocks:VariantNoVariants_fix' ).getString(  ) ];
else 
action_performed = "AllowZeroVariantControls is already 'on'";
end 
catch error

rethrow( error );
end 
end 


function nvss = filterInactiveNestedVSS( vss )


nvss = {  };
for i = 1:size( vss, 1 )
parent = get_param( vss{ i }, 'Parent' );
while ( ~strcmp( get_param( parent, 'type' ), 'block_diagram' ) )
if ( ~strcmp( parent, bdroot ) && strcmp( get_param( parent, 'Variant' ), 'on' ) )
nvss{ end  + 1, 1 } = vss{ i };
break ;
end 
parent = get_param( parent, 'Parent' );
end 
end 
end 




function action_performed = fixAllVariantSubsystemEnableAZVC( varargin )

nvss = filterInactiveNestedVSS( find_system( bdroot, 'MatchFilter', @Simulink.match.allVariants,  ...
'BlockType', 'SubSystem', 'Variant', 'on', 'AllowZeroVariantControls', 'off' ) );
try 

action_performed = [ message( 'Simulink:blocks:VariantNoVariantsFixAll_fix', newline ).getString(  ) ];
for i = 1:size( nvss, 1 )
set_param( nvss{ i }, 'AllowZeroVariantControls', 'on' );
action_performed = [ action_performed, nvss{ i }, newline ];
end 


action_performed( length( action_performed ) - 1 ) = '.';
catch error

rethrow( error );
end 
end 





function vsOrOutport = fixSetFunctionCallParam( varargin )
vsOrOutport = {  };
try 
vsOrOutport = varargin{ 1 }{ 1 };
paramVal = varargin{ 1 }{ 2 };
outBlkHandle = get_param( vsOrOutport, 'Handle' );
set_param( outBlkHandle, 'OutputFunctionCall', paramVal );
catch error

rethrow( error );
end 
end 





function action_performed = fixUnsetOutputWhenUnconnectedParam( varargin )
outputBlk = varargin{ 1 }{ 1 };

try 
set_param( outputBlk, 'OutputWhenUnconnected', 'off' );
action_performed = message( 'Simulink:Variants:OutputWhenUnconnected_fix', outputBlk ).getString(  );
catch error

rethrow( error );
end 
end 

% Decoded using De-pcode utility v1.2 from file /tmp/tmpW0JH4x.p.
% Please follow local copyright laws when handling this file.

