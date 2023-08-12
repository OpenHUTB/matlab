function portInfo = pil_configure_io_ports( pilMdlBlkHandle, model )













inportInfo = i_configure_inports( pilMdlBlkHandle, model );


outportInfo = i_configure_outports( pilMdlBlkHandle, model );

portInfo = [ inportInfo, outportInfo ];

dstModel = get_param( pilMdlBlkHandle, 'Parent' );
mapInfo.SourceModel = model;
mapInfo.Mapping = portInfo;
try 
set_param( dstModel, 'XILLoggingPathMapping', mapInfo );
catch me %#ok<NASGU>


end 
i_add_dummy_blocks( dstModel );


function inportInfo = i_configure_inports( pilMdlBlkHandle, srcModel )

portHandles = get_param( pilMdlBlkHandle, 'portHandles' );
numInports = length( portHandles.Inport );
dstModel = get_param( pilMdlBlkHandle, 'Parent' );


if ~isempty( findFcnCallRootInport( srcModel ) )
isExpFcn = true;
else 
isExpFcn = false;
end 

blkPosn = [ 20, 113, 50, 127 ];
blkPosnInc = [ 0, 25, 0, 25 ];
relTermPosn = [ 50, 0, 65, 7 ];

inportInfo = i_getEmptyPortInfo;

for port_idx = 1:numInports
srcBlkCA = find_system( srcModel, 'SearchDepth', 1,  ...
'BlockType', 'Inport',  ...
'Port', num2str( port_idx ) );
if isempty( srcBlkCA )




break ;
end 


isBusElementPrt = i_is_bus_element_port( srcBlkCA );





if isBusElementPrt


busBlk = [ dstModel, '/', 'Inport' ];
srcPrtName = get_param( srcBlkCA{ 1 }, 'PortName' );
srcPrtElement = '';
busBlk = coder.connectivity.TopModelSILPIL.addBusElementBlock(  ...
dstModel, busBlk, 'In', srcPrtName, srcPrtElement, blkPosn );


lineToBlkInPrt = portHandles.Inport( port_idx );
blkPosn = blkPosn + blkPosnInc;
ph = get_param( busBlk, 'PortHandles' );
add_line( dstModel, ph.Outport( 1 ),  ...
lineToBlkInPrt,  ...
'autorouting', 'on' );

end 


for sig_idx = 1:length( srcBlkCA )

srcBlk = srcBlkCA{ sig_idx };
srcBlkName = get_param( srcBlk, 'Name' );
dstBlk = [ dstModel, '/', 'Inport' ];


if isBusElementPrt



srcPrtName = get_param( srcBlk, 'PortName' );
srcPrtElement = get_param( srcBlk, 'Element' );
dstBlk = coder.connectivity.TopModelSILPIL.addBusElementBlock(  ...
dstModel, dstBlk, 'In', srcPrtName, srcPrtElement, blkPosn );


termPos = blkPosn + relTermPosn;
termBlk = coder.connectivity.TopModelSILPIL.addTerminatorBlock( dstModel, termPos );
termBlkPh = get_param( termBlk, 'PortHandles' );
lineToBlkInPrt = termBlkPh.Inport( 1 );

else 


lineToBlkInPrt = portHandles.Inport( port_idx );

dstBlk = add_block( 'built-in/Inport', dstBlk,  ...
'MakeNameUnique', 'on',  ...
'Position', blkPosn );
end 

blkPosn = blkPosn + blkPosnInc;

ph = get_param( dstBlk, 'PortHandles' );


add_line( dstModel, ph.Outport( 1 ),  ...
lineToBlkInPrt,  ...
'autorouting', 'on' );




i_copy_io_port_params( srcBlk, dstBlk );



if isExpFcn &&  ...
~isBusElementPrt &&  ...
i_has_bus_type( dstBlk )

set_param( dstBlk, 'BusOutputAsStruct', 'on' );

end 


set_param( dstBlk, 'Name', srcBlkName );


srcBlkPh = get_param( srcBlk, 'PortHandles' );


sigName = get_param( srcBlkPh.Outport, 'Name' );
set_param( ph.Outport, 'Name', sigName );





if strcmp( 'on', get_param( srcBlkPh.Outport, 'DataLogging' ) )

inportInfo( end  + 1 ) = setLoggingParams( srcBlkPh.Outport, ph.Outport );%#ok<AGROW>

escapedSrcBlkName = strrep( srcBlkName, '/', '//' );
escapedSrcBlkName = strrep( escapedSrcBlkName, newline, ' ' );
inportInfo( end  ).IlBlockPath = [ dstModel, '/', escapedSrcBlkName ];
inportInfo( end  ).IlPortIndex = 1;

end 
end 



if isBusElementPrt



i_copy_bus_element_data_types( srcBlkCA{ 1 }, busBlk );
end 

end 

function outportInfo = i_configure_outports( pilMdlBlkHandle, srcModel )

portHandles = get_param( pilMdlBlkHandle, 'portHandles' );
numOutports = length( portHandles.Outport );
dstModel = get_param( pilMdlBlkHandle, 'Parent' );
pilMdlBlkName = get_param( pilMdlBlkHandle, 'Name' );


outportBlks = find_system( srcModel, 'SearchDepth', 1, 'BlockType', 'Outport' );
numOutportBlks = length( outportBlks );
blkNum = 1;

blkPosn = [ 600, 113, 630, 127 ];
blkPosnInc = [ 0, 25, 0, 25 ];
relBusPosn = [  - 50,  - 7,  - 75,  + 7 ];
relTermPosn = [ 50, 0, 65, 7 ];
busPosn = blkPosn + [  - 50,  - 20,  - 50,  - 20 ];
srcPortList = zeros( 1, numOutportBlks );

outportInfo = i_getEmptyPortInfo;

for port_idx = 1:numOutports
outBlkOrigCA = find_system( srcModel, 'SearchDepth', 1,  ...
'BlockType', 'Outport',  ...
'Port', num2str( port_idx ) );
if isempty( outBlkOrigCA )




break ;
end 


isBusElementPrt = i_is_bus_element_port( outBlkOrigCA );

haveFullBEP = false;
if isBusElementPrt


elementsOnPort = get_param( outBlkOrigCA, 'Element' );
haveFullBEP = any( matches( elementsOnPort, '' ) );







if ~haveFullBEP




busBlk = [ dstModel, '/', 'Outport' ];
outBlkOrigPrtName = get_param( outBlkOrigCA{ 1 }, 'PortName' );
outBlkOrigElement = '';

busBlk = coder.connectivity.TopModelSILPIL.addBusElementBlock(  ...
dstModel, busBlk, 'Out', outBlkOrigPrtName, outBlkOrigElement, blkPosn );

lineToBlkOutPrt = portHandles.Outport( port_idx );
blkPosn = blkPosn + blkPosnInc;
ph = get_param( busBlk, 'PortHandles' );
add_line( dstModel, lineToBlkOutPrt, ph.Inport( 1 ),  ...
'autorouting', 'on' );



signalsToLog = get_param( outBlkOrigCA, 'Element' );


busSelectorH = coder.connectivity.TopModelSILPIL.addBusSelectorBlock( dstModel, signalsToLog, busPosn );


busSelectorPh = get_param( busSelectorH, 'PortHandles' );
add_line( dstModel, lineToBlkOutPrt, busSelectorPh.Inport( 1 ),  ...
'autorouting', 'on' );


busSelectorOutPh = busSelectorPh.Outport;

end 
end 

for sig_idx = 1:length( outBlkOrigCA )


outBlkOrig = outBlkOrigCA{ sig_idx };
outBlkOrigName = get_param( outBlkOrig, 'Name' );
dstBlk = [ dstModel, '/', 'Outport' ];


if isBusElementPrt


outBlkOrigElement = get_param( outBlkOrig, 'Element' );

if haveFullBEP



outBlkOrigPrtName = get_param( outBlkOrig, 'PortName' );
outBlk = coder.connectivity.TopModelSILPIL.addBusElementBlock( dstModel, dstBlk,  ...
'Out', outBlkOrigPrtName, outBlkOrigElement, blkPosn );
else 







termPos = blkPosn + relTermPosn;
outBlk = coder.connectivity.TopModelSILPIL.addTerminatorBlock( dstModel, termPos );
end 

else 


outBlk = add_block( 'built-in/Outport', dstBlk,  ...
'MakeNameUnique', 'on', 'Position', blkPosn );
end 


blkPosn = blkPosn + blkPosnInc;
busPosn = blkPosn + relBusPosn;


blkPh = get_param( outBlk, 'PortHandles' );

if isBusElementPrt && ~haveFullBEP




busSelPh = busSelectorOutPh( matches( signalsToLog, outBlkOrigElement ) );



targPrtH = busSelPh;
targPrtName = get_param( get_param( busSelPh, 'Parent' ), 'Name' );
targPrtNum = get_param( busSelPh, 'PortNumber' );


add_line( dstModel, busSelPh, blkPh.Inport( 1 ), 'autorouting', 'on' );

else 





targPrtH = portHandles.Outport( port_idx );
targPrtName = pilMdlBlkName;
targPrtNum = port_idx;

add_line( dstModel, targPrtH, blkPh.Inport( 1 ),  ...
'autorouting', 'on' );

if ~isBusElementPrt


i_copy_io_port_params( outBlkOrig, outBlk );
end 


set_param( outBlk, 'Name', outBlkOrigName );

end 

outportLh = get_param( outBlkOrig, 'LineHandles' );
outportConnectivity = get_param( outBlkOrig, 'PortConnectivity' );

processSignalName = true;
if isequal(  - 1, outportLh.Inport )

processSignalName = false;
else 
srcPortH = get_param( outportLh.Inport, 'SrcPortHandle' );
if isequal(  - 1, srcPortH )

processSignalName = false;
end 
end 

setSignalNameFromSrcPrt = true;
if isBusElementPrt





bepConnectsToInport = strcmp( 'Inport', get_param(  ...
outportConnectivity.SrcBlock, 'BlockType' ) );

if ~( bepConnectsToInport && haveFullBEP )
setSignalNameFromSrcPrt = false;
end 
end 

signalPropagation = '';
sigNameMatchesPropagatedSigName = false;
if processSignalName












sigName = get_param( srcPortH, 'Name' );
if ~isempty( regexp( sigName, '^<.*>$', 'once' ) )
sigNameMatchesPropagatedSigName = true;
end 
line = get( srcPortH, 'Line' );
signalPropagation = get( line, 'signalPropagation' );
end 

if sigNameMatchesPropagatedSigName && ~isBusElementPrt

if isempty( get_param( outBlk, 'SignalName' ) )
set_param( outBlk, 'SignalName', sigName );
end 
end 

if ~processSignalName

continue ;
end 

sigPortHandle = portHandles.Outport( port_idx );




if ~sigNameMatchesPropagatedSigName && setSignalNameFromSrcPrt
set_param( sigPortHandle, 'Name', sigName );
end 






if strcmp( signalPropagation, 'on' )
line = get( sigPortHandle, 'Line' );
set( line, 'signalPropagation', signalPropagation );
end 



if ~strcmp( 'Inport', get_param( outportConnectivity.SrcBlock, 'BlockType' ) )



isUniqueSignal = 1;
for k = 1:numOutportBlks
if isequal( srcPortH, srcPortList( k ) )
isUniqueSignal = 0;
break ;
end 
end 




if strcmp( 'on', get_param( srcPortH, 'DataLogging' ) )

if isUniqueSignal




if isBusElementPrt && ~haveFullBEP
outportInfo( end  + 1 ) = setLoggingParams( srcPortH, targPrtH );%#ok<AGROW>




if ~strcmp( 'Custom', get_param( targPrtH, 'DataLoggingNameMode' ) )
set_param( targPrtH, 'DataLoggingNameMode', 'Custom' );
set_param( targPrtH, 'DataLoggingName', sigName );
end 

outportInfo( end  ).IlBlockPath = [ dstModel, '/', targPrtName ];
outportInfo( end  ).IlPortIndex = targPrtNum;

else 
outportInfo( end  + 1 ) = setLoggingParams( srcPortH, sigPortHandle );%#ok<AGROW>                        
if sigNameMatchesPropagatedSigName

if ~strcmp( 'Custom', get_param( sigPortHandle, 'DataLoggingNameMode' ) )
set_param( sigPortHandle, 'DataLoggingNameMode', 'Custom' );
set_param( sigPortHandle, 'DataLoggingName', sigName );
end 
end 

outportInfo( end  ).IlBlockPath = [ dstModel, '/', targPrtName ];
outportInfo( end  ).IlPortIndex = targPrtNum;
end 



srcPortList( blkNum ) = srcPortH;
end 
end 
end 

blkNum = blkNum + 1;

end 
end 


function portInfo = i_getEmptyPortInfo
portInfo = struct( 'BlockPath', {  },  ...
'PortIndex', {  },  ...
'IlBlockPath', {  },  ...
'IlPortIndex', {  } );

function portInfo = setLoggingParams( srcHdl, dstHdl )


portInfo = i_getEmptyPortInfo;

portInfo( end  + 1 ).BlockPath = strrep( get_param( srcHdl, 'Parent' ),  ...
newline, ' ' );
portInfo( end  ).PortIndex = get_param( srcHdl, 'PortNumber' );


if strcmp( 'Custom', get_param( srcHdl, 'DataLoggingNameMode' ) )

loggingName = get_param( srcHdl, 'DataLoggingName' );

set_param( dstHdl, 'DataLoggingName',  ...
loggingName );

set_param( dstHdl, 'DataLoggingNameMode',  ...
get_param( srcHdl, 'DataLoggingNameMode' ) );
end 



set_param( dstHdl, 'DataLoggingDecimateData',  ...
get_param( srcHdl, 'DataLoggingDecimateData' ) );

set_param( dstHdl, 'DataLoggingDecimation',  ...
get_param( srcHdl, 'DataLoggingDecimation' ) );

set_param( dstHdl, 'DataLoggingLimitDataPoints',  ...
get_param( srcHdl, 'DataLoggingLimitDataPoints' ) );

set_param( dstHdl, 'DataLoggingMaxPoints',  ...
get_param( srcHdl, 'DataLoggingMaxPoints' ) );

set_param( dstHdl, 'DataLogging', 'on' );



function i_copy_io_port_params( srcBlk, dstBlk )


params = get_param( srcBlk, 'DialogParameters' );

paramNames = fieldnames( params );

paramNames{ end  + 1 } = 'SamplingMode';



paramNames{ end  + 1 } = 'Priority';



paramNames( strcmp( 'OutDataTypeStr', paramNames ) ) = [  ];






if ~i_is_bus_element_port( srcBlk )
paramNames{ end  + 1 } = 'OutDataTypeStr';
end 

for i = 1:length( paramNames )



if strcmp( paramNames{ i }, 'IsBusElementPort' ) == 1 ||  ...
strcmp( paramNames{ i }, 'StorageClass' ) == 1 ||  ...
strcmp( paramNames{ i }, 'SignalObject' ) == 1
continue ;
end 








if strcmp( paramNames{ i }, 'Port' ) ...
 || strcmp( paramNames{ i }, 'PortName' ) ...
 || strcmp( paramNames{ i }, 'Element' ) ...
 || strcmp( paramNames{ i }, 'BusVirtuality' ) ...
 || strcmp( paramNames{ i }, 'DataMode' ) ...
 || strcmp( paramNames{ i }, 'MessageQueueUseDefaultAttributes' ) ...
 || strcmp( paramNames{ i }, 'MessageQueueCapacity' ) ...
 || strcmp( paramNames{ i }, 'MessageQueueType' ) ...
 || strcmp( paramNames{ i }, 'MessageQueueOverwriting' )
continue ;
end 

set_param( dstBlk, paramNames{ i },  ...
get_param( srcBlk, paramNames{ i } ) );
end 


function hasBEP = i_is_bus_element_port( blocks )



if strcmp( get_param( blocks, 'IsBusElementPort' ), 'on' )
hasBEP = true;
else 
hasBEP = false;
end 

function hasBus = i_has_bus_type( blk )

hasBus = ~isempty( regexp( get_param( blk, 'OutDataTypeStr' ), '^Bus:', 'match' ) );


function i_copy_bus_element_data_types( srcBlk, dstBlk )


srcElements = coder.connectivity.TopModelSILPIL.getBusElementsFromTree( srcBlk );



srcElements = sortrows( srcElements, 'ascend' );


alreadySetType = false( length( srcElements ), 1 );
alreadySetDataMode = false( length( srcElements ), 1 );

for i = 1:length( srcElements )

srcNode = coder.connectivity.TopModelSILPIL.getTreeNode( get_param( srcBlk, 'Handle' ), srcElements{ i } );
srcDataType = Simulink.internal.CompositePorts.TreeNode.getDataType( srcNode );

dstNode = coder.connectivity.TopModelSILPIL.getTreeNode( get_param( dstBlk, 'Handle' ), srcElements{ i } );
srcDataTypeIsBus = startsWith( deblank( srcDataType ), 'Bus:' );


if ~alreadySetType( i )
Simulink.internal.CompositePorts.TreeNode.setDataTypeCL( dstNode, srcDataType );
if srcDataTypeIsBus

alreadySetType = alreadySetType + contains( srcElements, srcElements( i ) );
end 
end 


srcVirtuality = sl.mfzero.treeNode.Virtuality.INHERIT;
if srcDataTypeIsBus
srcVirtuality = Simulink.internal.CompositePorts.TreeNode.getVirtuality( srcNode );
Simulink.internal.CompositePorts.TreeNode.setVirtualityCL( dstNode, srcVirtuality );
end 


if ~alreadySetDataMode( i )

srcDataMode = Simulink.internal.CompositePorts.TreeNode.getDataMode( srcNode );
Simulink.internal.CompositePorts.TreeNode.setDataModeCL( dstNode, srcDataMode );



if srcVirtuality == sl.mfzero.treeNode.Virtuality.NON_VIRTUAL ||  ...
srcDataMode ~= sl.mfzero.treeNode.DataMode.INHERIT
alreadySetDataMode = alreadySetDataMode + contains( srcElements, srcElements( i ) );
end 
end 


qUseDefaultAttrs = Simulink.internal.CompositePorts.TreeNode.getQueueUseDefaultAttrs( srcNode );
Simulink.internal.CompositePorts.TreeNode.setQueueUseDefaultAttrsCL( dstNode, qUseDefaultAttrs );
qCapacity = Simulink.internal.CompositePorts.TreeNode.getQueueCapacity( srcNode );
Simulink.internal.CompositePorts.TreeNode.setQueueCapacityCL( dstNode, qCapacity );
qType = Simulink.internal.CompositePorts.TreeNode.getQueueType( srcNode );
Simulink.internal.CompositePorts.TreeNode.setQueueTypeCL( dstNode, qType );
qOverwriting = Simulink.internal.CompositePorts.TreeNode.getQueueOverwriting( srcNode );
Simulink.internal.CompositePorts.TreeNode.setQueueOverwritingCL( dstNode, qOverwriting );
end 

function i_add_dummy_blocks( dstModel )






ground = add_block( 'built-in/Ground', [ dstModel, '/Ground' ], 'MakeNameUnique', 'on' );
sigspec = add_block( 'built-in/SignalSpecification', [ dstModel, '/SigSpec' ], 'MakeNameUnique', 'on' );
terminator = add_block( 'built-in/Terminator', [ dstModel, '/Terminator' ], 'MakeNameUnique', 'on' );
groundName = get_param( ground, 'Name' );
sigspecName = get_param( sigspec, 'Name' );
terminatorName = get_param( terminator, 'Name' );
add_line( dstModel, [ groundName, '/1' ],  ...
[ sigspecName, '/1' ],  ...
'autorouting', 'on' );
add_line( dstModel, [ sigspecName, '/1' ],  ...
[ terminatorName, '/1' ],  ...
'autorouting', 'on' );
set_param( sigspec, 'OutDataTypeStr', 'int32' );
set_param( sigspec, 'Dimensions', '1' );



% Decoded using De-pcode utility v1.2 from file /tmp/tmpq1EYvj.p.
% Please follow local copyright laws when handling this file.

