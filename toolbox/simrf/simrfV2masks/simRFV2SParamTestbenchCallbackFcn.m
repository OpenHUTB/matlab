function simRFV2SParamTestbenchCallbackFcn( block, action )




top_sys = bdroot( block );
if strcmpi( get_param( top_sys, 'BlockDiagramType' ), 'library' )
return ;
end 

idxMaskNames = simrfV2getblockmaskparamsindex( block );
MaskWSValues = simrfV2getblockmaskwsvalues( block );
maskObj = get_param( block, 'MaskObject' );
simrfV2checkimpedance( MaskWSValues.Z0, 1, 'Impedance', 0 );

isRunningorPaused = any( strcmpi( get_param( top_sys, 'SimulationStatus' ),  ...
{ 'running', 'paused' } ) );
uncheckedIntConf = ~strcmp( get_param( block, 'UseIntConf' ), 'on' );

switch action
case 'simrfInit'
if ( isRunningorPaused )
return 
end 
MaskVals = get_param( block, 'MaskValues' );
MaskDisplay = sprintf( 'port_label(''output'',1,''S-Param'');' );

LinesOnMask = length( splitlines( get_param( block, 'MaskDisplay' ) ) );
internalGndStr = lower( MaskVals{ idxMaskNames.InternalGrounding } );
NumPorts = MaskWSValues.NumOfPorts;
validateattributes( NumPorts, { 'numeric' },  ...
{ 'nonempty', 'scalar', 'finite', 'integer', 'positive',  ...
'<=', 128 }, '', 'Number of ports' );
internalGnd = strcmp( internalGndStr, 'on' );
IndLastP = ( LinesOnMask - 1 ) / ( 1 + ( ~internalGnd ) );


if IndLastP ~= NumPorts

OldSPortElems = find_system( block, 'LookUnderMasks', 'all',  ...
'FollowLinks', 'on', 'SearchDepth', 1, 'FindAll', 'on',  ...
'RegExp', 'on', 'Name', 'SParamPort\d*' );
OldRFPortElems = find_system( block, 'LookUnderMasks', 'all',  ...
'FollowLinks', 'on', 'SearchDepth', 1, 'FindAll', 'on',  ...
'RegExp', 'on', 'Name', '[P|Gnd][\d*]' );



if ( IndLastP == length( OldSPortElems ) ) &&  ...
( IndLastP == length( OldRFPortElems ) / 2 )

numPRight = floor( NumPorts / 2 );
numPLeft = NumPorts - numPRight;
SPortStr = [ block, '/SParamPort', num2str( IndLastP ) ];
PosLastSPort = get_param( SPortStr, 'Position' );
deltaY = 2 * ( PosLastSPort( 4 ) - PosLastSPort( 2 ) );
deltaYTotLeft = deltaY * numPLeft;
deltaYTotRight = deltaY * numPRight;
MuxPosInit = get_param( [ 'simrfV2testbenches/' ...
, 'S-Parameter Testbench/Mux' ], 'Position' );
Mux2PosInit = get_param( [ 'simrfV2testbenches' ...
, '/S-Parameter Testbench/Mux2' ], 'Position' );


ah = find_system( block, 'LookUnderMasks', 'all',  ...
'FollowLinks', 'on', 'SearchDepth', 1,  ...
'FindAll', 'on',  ...
'AnnotationType', 'area_annotation' );
if contains( get_param( ah( 1 ), 'Name' ), 'RF' )
ahInd = 1;
else 
ahInd = 2;
end 
RFAreaPos = get_param( ah( ahInd ), 'Position' );
bc = get_param( ah( ahInd ), 'BackgroundColor' );



vecConPos = get_param( [ block, '/Vector Concatenate' ],  ...
'Position' );
vecConMidX = ( vecConPos( 3 ) + vecConPos( 1 ) ) / 2;
vecConDX = vecConPos( 3 ) - vecConPos( 1 );

if IndLastP > NumPorts




OldSPPortNums =  ...
str2double( regexp( get_param( OldSPortElems,  ...
'Name' ), '\d*', 'match', 'once' ) );
OldRFPPortNums =  ...
str2double( regexp( get_param( OldRFPortElems,  ...
'Name' ), '\d*', 'match', 'once' ) );
OldSPPort2Rem =  ...
find( OldSPPortNums > NumPorts );
OldRFPPort2Rem = OldRFPPortNums > NumPorts;
if length( OldSPPort2Rem ) == 1


ph = get_param(  ...
OldSPortElems( OldSPPort2Rem ), 'PortHandles' );
RFLines2Rem = cell2mat( get_param( ph.RConn, 'Line' ) );
slLines2Rem = get_param( [ ph.Inport ], 'Line' );
slLines2Rem = [ slLines2Rem; ...
get_param( [ ph.Outport ], 'Line' ) ];
else 
ph = cell2mat( get_param(  ...
OldSPortElems( OldSPPort2Rem ), 'PortHandles' ) );
RFLines2Rem = cell2mat( get_param( [ ph.RConn ],  ...
'Line' ) );
slLines2Rem = cell2mat( get_param( [ ph.Inport ],  ...
'Line' ) );
slLines2Rem = [ slLines2Rem; ...
cell2mat( get_param( [ ph.Outport ],  ...
'Line' ) ) ];
end 
delete( OldSPortElems( OldSPPort2Rem ) );
delete( OldRFPortElems( OldRFPPort2Rem ) );
delete_line( RFLines2Rem );
delete_line( slLines2Rem );



if numPLeft == 1
set_param( [ block, '/Mux' ], 'Position',  ...
MuxPosInit, 'Inputs', '1' );
else 
set_param( [ block, '/Mux' ], 'Position',  ...
MuxPosInit + [ 0,  - deltaY / 4, 0 ...
, deltaYTotLeft - deltaY / 2 - deltaY / 4 ], 'Inputs',  ...
num2str( numPLeft ) );
end 
if numPRight <= 1
set_param( [ block, '/Mux2' ], 'Position',  ...
Mux2PosInit, 'Inputs', '1' );
else 
set_param( [ block, '/Mux2' ], 'Position',  ...
Mux2PosInit + [ 0,  - deltaY / 4, 0 ...
, deltaYTotRight - deltaY / 2 - deltaY / 4 ], 'Inputs',  ...
num2str( numPRight ) );
end 

if numPRight == 0


phMux2 = get_param( [ block, '/Mux2' ], 'PortHandles' );
phMux3 = get_param( [ block, '/Mux3' ], 'PortHandles' );
add_line( block, phMux3.Outport, phMux2.Inport,  ...
'autorouting', 'on' );
end 


numPLeftRemoved = floor( ( IndLastP - NumPorts ) / 2 ) +  ...
mod( IndLastP - NumPorts, 2 ) * mod( IndLastP, 2 );
deltaYTotLeftRemoved = deltaY * numPLeftRemoved;
set_param( ah( ahInd ), 'position',  ...
RFAreaPos - [ 0, 0, 0, deltaYTotLeftRemoved ] );
set_param( [ block, '/Vector Concatenate' ], 'Position',  ...
vecConPos - [ 0, deltaYTotLeftRemoved, 0 ...
, deltaYTotLeftRemoved ] );



phVecCon = get_param( [ block, '/Vector Concatenate' ],  ...
'PortHandles' );
VecConOutLine = get_param( [ phVecCon.Outport ], 'Line' );
lPts = get_param( VecConOutLine, 'Points' );

if find( abs( lPts( :, 1 ) - vecConMidX ) < vecConDX / 2, 1 ) == 1

lPts( 2:3, 2 ) = lPts( 2:3, 2 ) - deltaYTotLeftRemoved;
else 

lPts( end  - 2:end  - 1, 2 ) = lPts( end  - 2:end  - 1, 2 ) -  ...
deltaYTotLeftRemoved;
end 
set_param( VecConOutLine, 'Points', lPts );



VecConInLines = get_param( [ phVecCon.Inport ], 'Line' );
lPts1 = get_param( VecConInLines{ 1 }, 'Points' );
lPts2 = get_param( VecConInLines{ 2 }, 'Points' );

if find( abs( lPts1( :, 1 ) - vecConMidX ) < vecConDX / 2, 1 ) == 1

lPts1( 2:3, 2 ) = lPts1( 2:3, 2 ) - deltaYTotLeftRemoved;
else 

lPts1( end  - 2:end  - 1, 2 ) = lPts1( end  - 2:end  - 1, 2 ) -  ...
deltaYTotLeftRemoved;
end 
set_param( VecConInLines{ 1 }, 'Points', lPts1 );
if find( abs( lPts2( :, 1 ) - vecConMidX ) < vecConDX / 2, 1 ) == 1

lPts2( 2:3, 2 ) = lPts2( 2:3, 2 ) - deltaYTotLeftRemoved;
else 

lPts2( end  - 2:end  - 1, 2 ) = lPts2( end  - 2:end  - 1, 2 ) -  ...
deltaYTotLeftRemoved;
end 
set_param( VecConInLines{ 2 }, 'Points', lPts2 );
else 

if IndLastP == 1


phMux3 = get_param( [ block, '/Mux3' ], 'PortHandles' );
delete_line( get_param( [ phMux3.Outport ], 'Line' ) );
end 


lib1Name = 'simrfV2private';
load_system( lib1Name );
lib2Name = 'nesl_utility_internal';
load_system( lib2Name );



if internalGnd
PNegStr = [ block, '/Gnd', num2str( IndLastP ) ];
lib3Name = 'simrfV2elements';
load_system( lib3Name );
else 
PNegStr = [ block, '/P', num2str( IndLastP ), '-' ];
end 


RFAreaDX = RFAreaPos( 3 ) - RFAreaPos( 1 );
midXLastSport = ( PosLastSPort( 1 ) + PosLastSPort( 3 ) ) / 2;
PPosStr = [ block, '/P', num2str( IndLastP ) ];
PosLastPPos = get_param( PPosStr, 'Position' );
midXLastPPos = ( PosLastPPos( 1 ) + PosLastPPos( 3 ) ) / 2;
deltaXSportPPos = abs( midXLastPPos - midXLastSport );
PPosdX = RFAreaDX - 2 * deltaXSportPPos;
PosLastPNeg = get_param( PNegStr, 'Position' );
midXLastPNeg = ( PosLastPNeg( 1 ) + PosLastPNeg( 3 ) ) / 2;
deltaXSportPNeg = abs( midXLastPNeg - midXLastSport );
PNegdX = RFAreaDX - 2 * deltaXSportPNeg;
numPLeftAdded = floor( ( NumPorts - IndLastP ) / 2 ) +  ...
mod( NumPorts - IndLastP, 2 ) * ( 1 - mod( IndLastP, 2 ) );
deltaYTotLeftAdded = deltaY * numPLeftAdded;


set_param( [ block, '/Vector Concatenate' ], 'Position',  ...
vecConPos + [ 0, deltaYTotLeftAdded, 0 ...
, deltaYTotLeftAdded ] );



phVecCon = get_param( [ block, '/Vector Concatenate' ],  ...
'PortHandles' );
VecConOutLine = get_param( [ phVecCon.Outport ], 'Line' );
lPts = get_param( VecConOutLine, 'Points' );

if find( abs( lPts( :, 1 ) - vecConMidX ) < vecConDX / 2, 1 ) == 1

lPts( 2:3, 2 ) = lPts( 2:3, 2 ) + deltaYTotLeftAdded;
else 

lPts( end  - 2:end  - 1, 2 ) = lPts( end  - 2:end  - 1, 2 ) +  ...
deltaYTotLeftAdded;
end 
set_param( VecConOutLine, 'Points', lPts );



VecConInLines = get_param( [ phVecCon.Inport ], 'Line' );
lPts1 = get_param( VecConInLines{ 1 }, 'Points' );
lPts2 = get_param( VecConInLines{ 2 }, 'Points' );

if find( abs( lPts1( :, 1 ) - vecConMidX ) < vecConDX / 2, 1 ) == 1

lPts1( 2:3, 2 ) = lPts1( 2:3, 2 ) + deltaYTotLeftAdded;
else 

lPts1( end  - 2:end  - 1, 2 ) = lPts1( end  - 2:end  - 1, 2 ) +  ...
deltaYTotLeftAdded;
end 
set_param( VecConInLines{ 1 }, 'Points', lPts1 );
if find( abs( lPts2( :, 1 ) - vecConMidX ) < vecConDX / 2, 1 ) == 1

lPts2( 2:3, 2 ) = lPts2( 2:3, 2 ) + deltaYTotLeftAdded;
else 

lPts2( end  - 2:end  - 1, 2 ) = lPts2( end  - 2:end  - 1, 2 ) +  ...
deltaYTotLeftAdded;
end 
set_param( VecConInLines{ 2 }, 'Points', lPts2 );
set_param( ah( ahInd ), 'position',  ...
RFAreaPos + [ 0, 0, 0, deltaYTotLeftAdded ] );
set_param( [ block, '/Mux' ], 'Position',  ...
MuxPosInit + [ 0,  - deltaY / 4, 0 ...
, deltaYTotLeft - deltaY / 2 - deltaY / 4 ], 'Inputs',  ...
num2str( numPLeft ) );
set_param( [ block, '/Mux2' ], 'Position',  ...
Mux2PosInit + [ 0,  - deltaY / 4, 0 ...
, deltaYTotRight - deltaY / 2 - deltaY / 4 ], 'Inputs',  ...
num2str( numPRight ) );


phMux = get_param( [ block, '/Mux' ], 'PortHandles' );
phMux1 = get_param( [ block, '/Mux1' ], 'PortHandles' );
phMux2 = get_param( [ block, '/Mux2' ], 'PortHandles' );
phMux3 = get_param( [ block, '/Mux3' ], 'PortHandles' );


orientations = { 'left', 'right' };
for AddedPInd = IndLastP + 1:NumPorts





leftSide = mod( AddedPInd, 2 );
if leftSide
posConfig = PosLastSPort +  ...
[  - RFAreaDX, deltaY,  - RFAreaDX, deltaY ];
posPPos = PosLastPPos +  ...
[  - PPosdX, deltaY,  - PPosdX, deltaY ];
posPNeg = PosLastPNeg +  ...
[  - PNegdX, deltaY,  - PNegdX, deltaY ];
phMuxOut = phMux1;
phMuxIn = phMux;
PNegNamePlace = 'alternate';
else 
posConfig = PosLastSPort +  ...
[ RFAreaDX, 0, RFAreaDX, 0 ];
posPPos = PosLastPPos + [ PPosdX, 0, PPosdX, 0 ];
posPNeg = PosLastPNeg + [ PNegdX, 0, PNegdX, 0 ];
phMuxOut = phMux3;
phMuxIn = phMux2;
PNegNamePlace = 'normal';
end 



Sporth = add_block( [ lib1Name ...
, '/SParamPortNoNoise' ],  ...
[ block, '/SParamPort', num2str( AddedPInd ) ],  ...
'Position', posConfig,  ...
'orientation', orientations{ leftSide + 1 },  ...
'ExcitationOn', [ 'SParamElem2Val(InputIdx) ' ...
, '== ', num2str( AddedPInd ) ],  ...
'Fin', 'Fin', 'Fout', 'Fout', 'Z0', 'Z0' );
phSport = get_param( Sporth, 'PortHandles' );
PPosh = add_block( [ lib2Name, '/Connection Port' ],  ...
[ block, '/P', num2str( AddedPInd ) ],  ...
'Position', posPPos,  ...
'orientation', orientations{ ~leftSide + 1 },  ...
'side', orientations{ ~leftSide + 1 },  ...
'NamePlacement', 'alternate' );
phP = get_param( PPosh, 'PortHandles' );
add_line( block, phSport.RConn( 1 ), phP.RConn,  ...
'autorouting', 'on' );




if internalGnd
Gndh = add_block( [ lib3Name, '/Gnd' ],  ...
[ block, '/Gnd', num2str( AddedPInd ) ],  ...
'Position', posPNeg,  ...
'orientation', 'down',  ...
'NamePlacement', PNegNamePlace,  ...
'BackgroundColor', bc );
phGnd = get_param( Gndh, 'PortHandles' );
add_line( block, phSport.RConn( 2 ),  ...
phGnd.LConn, 'autorouting', 'on' );
else 
PNegh = add_block(  ...
[ lib2Name, '/Connection Port' ],  ...
[ block, '/P', num2str( AddedPInd ), '-' ],  ...
'Position', posPNeg,  ...
'orientation', 'up',  ...
'side', orientations{ ~leftSide + 1 },  ...
'NamePlacement', PNegNamePlace );
phPNeg = get_param( PNegh, 'PortHandles' );
add_line( block, phSport.RConn( 2 ),  ...
phPNeg.RConn, 'autorouting', 'on' );
end 


add_line( block, phMuxOut.Outport,  ...
phSport.Inport, 'autorouting', 'smart' );
add_line( block, phSport.Outport,  ...
phMuxIn.Inport( floor( AddedPInd / 2 ) + leftSide ),  ...
'autorouting', 'smart' );

PosLastSPort = posConfig;
PosLastPPos = posPPos;
PosLastPNeg = posPNeg;
end 
end 
MaskDisplay = simrfV2_add_portlabel(  ...
MaskDisplay, numPLeft * ( 1 + ( ~internalGnd ) ),  ...
arrayfun( @( n )num2str( n ), ( 0:numPLeft - 1 ).' * 2 + 1,  ...
'UniformOutput', false ).',  ...
numPRight * ( 1 + ( ~internalGnd ) ),  ...
arrayfun( @( n )num2str( n ), ( 1:numPRight ).' * 2,  ...
'UniformOutput', false ).', internalGnd );
set_param( block, 'MaskDisplay', MaskDisplay );
end 
end 

switch internalGndStr
case 'on'

MinusRFPortElems = find_system( block, 'LookUnderMasks',  ...
'all', 'FollowLinks', 'on', 'SearchDepth', 1,  ...
'FindAll', 'on', 'RegExp', 'on', 'Name', 'P\d*-' );
if ~isempty( MinusRFPortElems )
ah = find_system( block, 'LookUnderMasks', 'all',  ...
'FollowLinks', 'on', 'SearchDepth', 1,  ...
'FindAll', 'on',  ...
'AnnotationType', 'area_annotation' );
if contains( get_param( ah( 1 ), 'Name' ), 'RF' )
ahInd = 1;
else 
ahInd = 2;
end 
bc = get_param( ah( ahInd ), 'BackgroundColor' );
MinusRFPortNames = get_param( MinusRFPortElems, 'Name' );
if ~iscell( MinusRFPortNames )
MinusRFPortNames = { MinusRFPortNames };
end 
for PInd = 1:length( MinusRFPortElems )
MinusRFPortNum = regexp( MinusRFPortNames{ PInd },  ...
'P(\d*)-', 'tokens' );
MinusRFPortNum = MinusRFPortNum{ 1 }{ 1 };
PSide = get_param( [ block, '/P', MinusRFPortNum ],  ...
'side' );
if strcmpi( PSide, 'left' )
GndNamePlace = 'alternate';
else 
GndNamePlace = 'normal';
end 
replace_gnd_complete = simrfV2repblk(  ...
struct( 'RepBlk', MinusRFPortNames{ PInd },  ...
'SrcBlk', 'simrfV2elements/Gnd',  ...
'SrcLib', 'simrfV2elements',  ...
'DstBlk', [ 'Gnd', MinusRFPortNum ],  ...
'Param', { { 'NamePlacement', GndNamePlace,  ...
'BackgroundColor', bc } } ), block );

if replace_gnd_complete
SPortStr = [ 'SParamPort', MinusRFPortNum ];
simrfV2connports( struct( 'SrcBlk', SPortStr,  ...
'SrcBlkPortStr', 'RConn',  ...
'SrcBlkPortIdx', 2,  ...
'DstBlk', [ 'Gnd', MinusRFPortNum ],  ...
'DstBlkPortStr', 'LConn',  ...
'DstBlkPortIdx', 1 ), block );
end 
end 
numPRight = floor( NumPorts / 2 );
numPLeft = NumPorts - numPRight;
PLeftNames = mat2cell( num2str( ( 1:2:2 * numPLeft ).' ),  ...
ones( 1, numPLeft ) );
PRightNames = mat2cell( num2str( ( 2:2:2 * numPRight ).' ),  ...
ones( 1, numPRight ) );
MaskDisplay = simrfV2_add_portlabel( MaskDisplay,  ...
numPLeft, PLeftNames, numPRight, PRightNames,  ...
true );
simrfV2_set_param( block, 'MaskDisplay', MaskDisplay );
end 

case 'off'

GndElems = find_system( block, 'LookUnderMasks', 'all',  ...
'FollowLinks', 'on', 'SearchDepth', 1, 'FindAll',  ...
'on', 'RegExp', 'on', 'Name', 'Gnd\d*' );
if ~isempty( GndElems )
GndNames = get_param( GndElems, 'Name' );
if ~iscell( GndNames )
GndNames = { GndNames };
end 
for GndInd = 1:length( GndElems )
GndNum = regexp( GndNames{ GndInd }, 'Gnd(\d*)',  ...
'tokens' );
GndNum = GndNum{ 1 }{ 1 };
PPosSide = get_param( [ block, '/P', GndNum ], 'side' );
if strcmpi( PPosSide, 'left' )
PNegNamePlace = 'alternate';
else 
PNegNamePlace = 'normal';
end 
replace_gnd_complete = simrfV2repblk(  ...
struct( 'RepBlk', GndNames{ GndInd }, 'SrcBlk',  ...
'nesl_utility_internal/Connection Port',  ...
'SrcLib', 'nesl_utility_internal',  ...
'DstBlk', [ 'P', GndNum, '-' ],  ...
'Param', { { 'Orientation', 'Up',  ...
'Port', num2str( str2double( GndNum ) * 2 ),  ...
'side', PPosSide,  ...
'NamePlacement', PNegNamePlace } } ), block );






if ~strcmpi( get_param( [ block, '/P', GndNum, '-' ],  ...
'Side' ), PPosSide )
set_param( [ block, '/P', GndNum, '-' ], 'Side',  ...
PPosSide );
end 
if replace_gnd_complete
SPortStr = [ 'SParamPort', GndNum ];
simrfV2connports( struct( 'SrcBlk', SPortStr,  ...
'SrcBlkPortStr', 'RConn',  ...
'SrcBlkPortIdx', 2,  ...
'DstBlk', [ 'P', GndNum, '-' ],  ...
'DstBlkPortStr', 'RConn',  ...
'DstBlkPortIdx', 1 ), block );
end 
end 
numPRight = floor( NumPorts / 2 );
numPLeft = NumPorts - numPRight;
PLeftNames = mat2cell( num2str( ( 1:2:2 * numPLeft ).' ),  ...
ones( 1, numPLeft ) );
PRightNames = mat2cell( num2str( ( 2:2:2 * numPRight ).' ),  ...
ones( 1, numPRight ) );
MaskDisplay = simrfV2_add_portlabel( MaskDisplay,  ...
2 * numPLeft, PLeftNames, 2 * numPRight,  ...
PRightNames, false );
simrfV2_set_param( block, 'MaskDisplay', MaskDisplay );
end 
end 


validateattributes( MaskWSValues.Fin, { 'numeric' },  ...
{ 'nonempty', 'scalar', 'finite', 'real', 'nonnegative' },  ...
'', 'Input frequency (Hz)' );

validateattributes( MaskWSValues.FoutInput, { 'numeric' },  ...
{ 'nonempty', 'scalar', 'finite', 'real', 'nonnegative' },  ...
'', 'Output frequency (Hz)' );
validateattributes( MaskWSValues.Base_bw, { 'numeric' },  ...
{ 'nonempty', 'scalar', 'finite', 'real', 'nonnegative' },  ...
'', 'Baseband bandwidth (Hz)' );


SParamElemPrev = MaskWSValues.SParamElemPrev;
if strcmp( get_param( block, 'MeasureAll' ), 'on' )
[ SPCol, SPRow ] = meshgrid( 1:NumPorts );
SParamElem = [ SPRow( : ), SPCol( : ) ];
if ~strcmpi( get_param( [ block, '/OutputTypeControl' ],  ...
'LabelModeActivechoice' ), 'MatrixType' ) &&  ...
isempty( regexpi( get_param( top_sys,  ...
'SimulationStatus' ), '^(updating|initializing)$' ) )


set_param( [ block, '/OutputTypeControl' ],  ...
'LabelModeActivechoice', 'MatrixType' );
end 
else 
SParamElem = MaskWSValues.SParamElem;
if ~strcmpi( get_param( [ block, '/OutputTypeControl' ],  ...
'LabelModeActivechoice' ), 'VectorType' ) &&  ...
isempty( regexpi( get_param( top_sys,  ...
'SimulationStatus' ), '^(updating|initializing)$' ) )


set_param( [ block, '/OutputTypeControl' ],  ...
'LabelModeActivechoice', 'VectorType' );
end 
end 
SParamChanged = ~all( size( SParamElem ) == size( SParamElemPrev ) ) ||  ...
~all( all( SParamElem == SParamElemPrev ) );
if SParamChanged

validateattributes( SParamElem, { 'numeric' },  ...
{ 'nonempty', '2d', 'ncols', 2, 'integer', 'finite',  ...
'nonsparse' }, '', 'S-parameter elements' );

if size( unique( SParamElem, 'rows', 'stable' ), 1 ) ~=  ...
size( SParamElem, 1 )
error( message( [ 'simrf:simrfV2errors:' ...
, 'TestbenchSParamNotUnique' ] ) );
end 


if any( find( SParamElem( : ) > NumPorts ) )
error( message( [ 'simrf:simrfV2errors:' ...
, 'TestbenchSParamLargerThanNumPorts' ] ) );
end 
end 


if ~isvarname( get_param( block, 'VarName' ) )
error( message( [ 'simrf:simrfV2errors:' ...
, 'TestbenchSParamInvalidVarName' ], 'VarName' ) );
end 

checkedSParam = strcmp( get_param( block, 'ShowSParam' ), 'on' ) &&  ...
hasDST;
SParamScopeConf = get_param( [ block, '/SParam' ],  ...
'ScopeConfiguration' );

if strcmpi( get_param( top_sys, 'Open' ), 'on' ) &&  ...
( SParamScopeConf.OpenAtSimulationStart ~= checkedSParam )
SParamScopeConf.OpenAtSimulationStart = checkedSParam;

SParamScopeConf.Visible = checkedSParam;
if checkedSParam
ShowSParamType = get_param( block, 'ShowSParamType' );
if strcmpi( ShowSParamType, 'Real & Imag' ) &&  ...
size( SParamElem, 1 ) > 50
error( message( [ 'simrf:simrfV2errors:' ...
, 'TestbenchSParamTooManyInChannels' ] ) );
elseif size( SParamElem, 1 ) > 100
error( message( [ 'simrf:simrfV2errors:' ...
, 'TestbenchSParamTooManyInChannels' ] ) );
end 

setChannelNames( block, SParamScopeConf, ShowSParamType,  ...
SParamElem );
end 
end 

if strcmp( get_param( block, 'ShowSParamType' ), 'Magnitude' )
if ~strcmpi( get_param( [ block, '/ScopeTypeControl' ],  ...
'LabelModeActivechoice' ), 'MagType' ) &&  ...
isempty( regexpi( get_param( top_sys,  ...
'SimulationStatus' ), '^(updating|initializing)$' ) )


set_param( [ block, '/ScopeTypeControl' ],  ...
'LabelModeActivechoice', 'MagType' );
end 
else 
if ~strcmpi( get_param( [ block, '/ScopeTypeControl' ],  ...
'LabelModeActivechoice' ), 'ReImType' ) &&  ...
isempty( regexpi( get_param( top_sys,  ...
'SimulationStatus' ), '^(updating|initializing)$' ) )


set_param( [ block, '/ScopeTypeControl' ],  ...
'LabelModeActivechoice', 'ReImType' );
end 
end 

if strcmp( get_param( block, 'AdjustForLargeSig' ), 'on' )
if ~strcmpi( get_param( [ block, '/SParam_Testbench' ],  ...
'LabelModeActivechoice' ), 'NonLinearType' ) &&  ...
isempty( regexpi( get_param( top_sys,  ...
'SimulationStatus' ), '^(updating|initializing)$' ) )


set_param( [ block, '/SParam_Testbench' ],  ...
'LabelModeActivechoice', 'NonLinearType' );



SParamChanged = true;
end 
else 
if ~strcmpi( get_param( [ block, '/SParam_Testbench' ],  ...
'LabelModeActivechoice' ), 'LinearType' ) &&  ...
isempty( regexpi( get_param( top_sys,  ...
'SimulationStatus' ), '^(updating|initializing)$' ) )


set_param( [ block, '/SParam_Testbench' ],  ...
'LabelModeActivechoice', 'LinearType' );



SParamChanged = true;
end 
end 




if ( uncheckedIntConf )
if ~isempty( simrfV2_find_repblk( block, 'Configuration' ) )
phRepBlk = get_param( [ block, '/Configuration' ],  ...
'PortHandles' );

simrfV2deletelines( get( phRepBlk.LConn, 'Line' ) )

simrfV2deletelines( get( phRepBlk.RConn, 'Line' ) )
delete_block( [ block, '/Configuration' ] )
end 
else 
if isempty( simrfV2_find_repblk( block, 'Configuration' ) )
load_system( 'simrfV2util1' );
pos_libConf =  ...
get_param( 'simrfV2util1/Configuration', 'Position' );
pos_inport = get_param( [ block, '/SParamPort1' ],  ...
'Position' );
deltaX = pos_libConf( 3 ) - pos_libConf( 1 );
deltaY = pos_libConf( 4 ) - pos_libConf( 2 );
posConfig = [ pos_inport( 3 ) + floor( 3 * deltaX / 4 ) ...
, pos_inport( 2 ) - deltaY + floor( deltaY * 1 / 8 ) ...
, pos_inport( 3 ) + floor( 3 * deltaX / 4 ) + deltaX ...
, pos_inport( 2 ) + floor( deltaY * 1 / 8 ) ];
src = 'simrfV2util1/Configuration';
ConfigHandle = add_block( src,  ...
[ block, '/Configuration' ], 'Position', posConfig );
set( ConfigHandle, 'StepSize', '(1/Base_bw)/OS',  ...
'AddNoise', 'off', 'EnableInterpFilter', 'off',  ...
'SimFreqs', 'SimFreqs',  ...
'Orientation', 'up', 'HideAutomaticName', 'off' );
phConfig1Handle = get( ConfigHandle, 'PortHandles' );
phSParamPort1 = get_param( [ block, '/SParamPort1' ],  ...
'PortHandles' );
addedLine = add_line( block, phSParamPort1.RConn( 1 ),  ...
phConfig1Handle.LConn( 1 ), 'autorouting', 'on' );

phRepBlk = get_param( [ block, '/Configuration' ],  ...
'PortHandles' );
ConfPortPos = get( phRepBlk.LConn, 'Position' );
LinePts = get( addedLine, 'Points' );
LinePts = [ LinePts( 1, : );LinePts( end , : ) ];
isConfPort = LinePts( :, 1 ) == ConfPortPos( 1, 1 );

LinePts = [ LinePts( 1, : ); ...
[ LinePts( isConfPort, 1 ), LinePts( ~isConfPort, 2 ) ]; ...
LinePts( 2, : ) ];

set( addedLine, 'Points', LinePts )
end 
end 


if SParamChanged
set_param( block, 'SParamElemPrev', mat2str( SParamElem ) );





[ SParamElem2Val, ~, SParamElem2Uind ] =  ...
unique( SParamElem( :, 2 ), 'stable' );
SParamElem1Cell = cell( length( SParamElem2Val ), 1 );
SParamElem1Len = zeros( length( SParamElem2Val ), 1 );
for SParamElem2Ind = 1:length( SParamElem2Val )
SParamElem1Cell{ SParamElem2Ind } =  ...
SParamElem( ismember( SParamElem( :, 2 ),  ...
SParamElem2Val( SParamElem2Ind ) ), 1 );
SParamElem1Len( SParamElem2Ind ) =  ...
length( SParamElem1Cell{ SParamElem2Ind } );
end 
maxLen = max( SParamElem1Len );
SParamElem1Ind = [  ];
SParamElem1Cellfull = cell( length( SParamElem2Val ), 1 );
SParamElem1CellMappedfull = cell( length( SParamElem2Val ), 1 );
if strcmp( get_param( block, 'AdjustForLargeSig' ), 'off' )









for SParamElem2Ind = 1:length( SParamElem2Val )
maxVal = max( SParamElem1Cell{ SParamElem2Ind } );
tempSParamVals = ones( maxLen, 1 ) * maxVal;
tempSParamVals( 1:length( SParamElem1Cell{  ...
SParamElem2Ind } ) ) = SParamElem1Cell{ SParamElem2Ind };
SParamElem1Cellfull{ SParamElem2Ind } = tempSParamVals.';
SParamElem1CellMappedfull{ SParamElem2Ind } =  ...
( mod( tempSParamVals - 1, 2 ) * ceil( NumPorts / 2 ) +  ...
floor( ( tempSParamVals - 1 ) / 2 ) + 1 ).';
SParamElem1Ind( end  + 1:end  + length( SParamElem1Cell{  ...
SParamElem2Ind } ) ) = ( SParamElem2Ind - 1 ) * maxLen +  ...
( 1:length( SParamElem1Cell{ SParamElem2Ind } ) );
end 
SParamElem1Sel = cell2mat( SParamElem1Cellfull );
SParamElem1SelMapped = cell2mat( SParamElem1CellMappedfull );
else 




All1Vals = unique( SParamElem( :, 1 ) );
maxLen = length( All1Vals );
for SParamElem2Ind = 1:length( SParamElem2Val )
SParamElem1Cellfull{ SParamElem2Ind } = All1Vals.';
SParamElem1CellMappedfull{ SParamElem2Ind } =  ...
( mod( All1Vals - 1, 2 ) * ceil( NumPorts / 2 ) +  ...
floor( ( All1Vals - 1 ) / 2 ) + 1 ).';
memberInd = find( ismember(  ...
SParamElem1Cellfull{ SParamElem2Ind },  ...
SParamElem1Cell{ SParamElem2Ind } ) );
SParamElem1Ind( end  + 1:end  + length( SParamElem1Cell{  ...
SParamElem2Ind } ) ) = ( SParamElem2Ind - 1 ) * maxLen +  ...
memberInd;
end 
SParamElem1Sel = cell2mat( SParamElem1Cellfull );
SParamElem1SelMapped = cell2mat( SParamElem1CellMappedfull );


SParamElem2Val = [ SParamElem2Val( 1 );SParamElem2Val ];
SParamElem1Sel = [ SParamElem1Sel( 1, : );SParamElem1Sel ];
SParamElem1SelMapped = [ SParamElem1SelMapped( 1, : ); ...
SParamElem1SelMapped ];
end 


[ ~, invSParamElem2Uind ] = sort( SParamElem2Uind );
SParamElem1Ind = SParamElem1Ind( invSParamElem2Uind );
set_param( block, 'SParamElem2Val', mat2str( SParamElem2Val ) );
set_param( block, 'SParamElem1Sel', mat2str( SParamElem1Sel ) );
set_param( block, 'SParamElem1SelMapped',  ...
mat2str( SParamElem1SelMapped ) );
set_param( block, 'SParamElem1Ind', mat2str( SParamElem1Ind ) );


set_param( block, 'InputIdx', '1' );
end 


if ~isempty( simrfV2_find_dialog( block ) )
[ Y, ~, U ] = engunits( MaskWSValues.Nbins / MaskWSValues.Base_bw );
MaxSpanControl = maskObj.getDialogControl(  ...
'TextTimeSpanStr' );
MaxSpanControl.Prompt = [ 'Measurement time: ', num2str( Y ), U ...
, 's' ];
end 

fft_size = MaskWSValues.Nbins * MaskWSValues.OS;
simrfV2_set_param( block, 'fft_size', num2str( fft_size ) );


if length( MaskWSValues.resp ) ~= fft_size ||  ...
MaskWSValues.OS ~= MaskWSValues.respOS
maxlen = fft_size;
f_ps = 0.6 * MaskWSValues.Base_bw;
f_st = 0.7 * MaskWSValues.Base_bw;
ps_att = 10 * log10( 2 );
st_att = 60;
ts = 1 / ( MaskWSValues.Base_bw * MaskWSValues.OS );
filterObj = rffilter( 'FilterType', 'Butterworth',  ...
'ResponseType', 'Lowpass',  ...
'Implementation', 'Transfer function',  ...
'Zin', 50, 'Zout', 50,  ...
'PassbandFrequency', f_ps,  ...
'StopbandFrequency', f_st,  ...
'PassbandAttenuation', ps_att,  ...
'StopbandAttenuation', st_att );
ifftlen = 2 ^ ceil( log2( maxlen ) );
freq_pos = ( 0:ifftlen / 2 ) * ( 1 / ts ) / ifftlen;
Sparam = sparameters( filterObj, freq_pos );
transf_pos = rfparam( Sparam, 2, 1 );
transf = [ conj( flipud( transf_pos ) );transf_pos( 2:end  - 1 ) ];
resp = real( ifft( fftshift( transf( : ) ) ) );
set_param( gcb, 'resp', mat2str( resp ) );
set_param( gcb, 'respOS', num2str( MaskWSValues.OS ) );
end 

if strcmp( get_param( block, 'AdjustForLargeSig' ), 'on' )
simrfV2_set_param( block, 'Fout',  ...
num2str( MaskWSValues.FoutInput ) );
else 
simrfV2_set_param( block, 'Fout', num2str( MaskWSValues.Fin ) );
end 

if ~uncheckedIntConf
if strcmp( get_param( block, 'SmallSignalApprox' ), 'on' )
simrfV2_set_param( [ block, '/Configuration' ],  ...
'SmallSignalApprox', 'on' );
AllSimFreqs = get_param( block, 'AllSimFreqs' );
if ~strcmpi( get_param( [ block, '/Configuration' ],  ...
'AllSimFreqs' ), AllSimFreqs )
set_param( [ block, '/Configuration' ],  ...
'AllSimFreqs', AllSimFreqs );
if strcmpi( AllSimFreqs, 'off' )

validateattributes( MaskWSValues.SimFreqs,  ...
{ 'numeric' }, { 'nonempty', 'row', 'finite',  ...
'real', 'nonnegative' }, block,  ...
'specified frequencies' )
end 
end 
else 
simrfV2_set_param( [ block, '/Configuration' ],  ...
'SmallSignalApprox', 'off' );
end 
end 

if regexpi( get_param( top_sys, 'SimulationStatus' ),  ...
'^(updating|initializing)$' )


set_param( block, 'InputIdx', '1' );
SParamScopeConf = get_param( [ block, '/SParam' ],  ...
'ScopeConfiguration' );
ShowSParamType = get_param( block, 'ShowSParamType' );
setChannelNames( block, SParamScopeConf, ShowSParamType,  ...
SParamElem );
if strcmp( get_param( block, 'AdjustForLargeSig' ), 'off' )


set_param( block, 'ResetableRand', num2str( rand, '%.16e' ) );
else 









set_param( block, 'ResetableRand', 'eps(1)' );
end 
if ~uncheckedIntConf
MaskTunableValues = get_param( block, 'MaskTunableValues' );
if strcmp( get_param( block, 'SmallSignalApprox' ), 'on' )
MaskTunableValues{ idxMaskNames.T_amp_dBm } = 'off';
else 
MaskTunableValues{ idxMaskNames.T_amp_dBm } = 'on';
end 
set_param( block, 'MaskTunableValues', MaskTunableValues );
end 












end 
return 
otherwise 

switch action
case 'IntConfboxCallback'
MaskVis = get_param( block, 'MaskVisibilities' );
idxMaskNames = simrfV2getblockmaskparamsindex( block );
if ~uncheckedIntConf
if strcmp( MaskVis{ idxMaskNames.SmallSignalApprox },  ...
'off' )
MaskVis{ idxMaskNames.SmallSignalApprox } = 'on';
set_param( block, 'MaskVisibilities', MaskVis );
SmallSigDialogControl( block, maskObj, MaskVis,  ...
idxMaskNames );
end 
elseif strcmp( MaskVis{ idxMaskNames.SmallSignalApprox },  ...
'on' )
MaskVis{ idxMaskNames.SmallSignalApprox } = 'off';
MaskVis{ idxMaskNames.AllSimFreqs } = 'off';
MaskVis{ idxMaskNames.SimFreqs } = 'off';
maskObj.getDialogControl(  ...
'PopFreqContainer' ).Visible = 'off';
set_param( block, 'MaskVisibilities', MaskVis );
end 


ButtonEn = 'on';
ButtonControl = maskObj.getDialogControl( 'SaveButton' );
sXpStr = num2str( MaskWSValues.NumOfPorts );
ButtonControl.Prompt =  ...
[ '  Export measurement result to s', sXpStr, 'p  ' ];
if isRunningorPaused
ButtonEn = 'off';
else 
UsrData = get_param( [ block, '/Terminate Function' ],  ...
'UserData' );
[ SPCol, SPRow ] = meshgrid( 1:MaskWSValues.NumOfPorts );
SParamElem = [ SPRow( : ), SPCol( : ) ];
if ~isfield( UsrData, 'SParamElem' ) ||  ...
( ~all( size( MaskWSValues.SParamElemPrev ) ==  ...
size( SParamElem ) ) ||  ...
~all( all( MaskWSValues.SParamElemPrev ==  ...
SParamElem ) ) )


ButtonEn = 'off';
end 
end 
if ~strcmp( ButtonControl.Enabled, ButtonEn )
ButtonControl.Enabled = ButtonEn;
end 



NbinsCurrent = slResolve( get_param( block, 'Nbins' ), block );
Base_bwCurrent = slResolve( get_param( block, 'Base_bw' ),  ...
block );
[ Y, ~, U ] = engunits( NbinsCurrent / Base_bwCurrent );
MaxSpanControl = maskObj.getDialogControl(  ...
'TextTimeSpanStr' );
MaxSpanControl.Prompt = [ 'Measurement time: ' ...
, num2str( Y ), U, 's' ];

case 'ShowSParamSpectCallback'
if ( ~isRunningorPaused )
ContainerShowSParam = maskObj.getDialogControl(  ...
'ContainerShowSParam' );
if ( hasDST )
if ( strcmp( ContainerShowSParam.Visible, 'off' ) )
ContainerShowSParam.Visible = 'on';





checkedSParam = strcmp( get_param( block,  ...
'ShowSParam' ), 'on' );
SParamScopeConf = get_param( [ block ...
, '/SParam' ], 'ScopeConfiguration' );
if checkedSParam &&  ...
~SParamScopeConf.OpenAtSimulationStart
SParamScopeConf.OpenAtSimulationStart = true;
end 
end 
MaskEnables = get_param( block, 'MaskEnables' );
idxMaskNames =  ...
simrfV2getblockmaskparamsindex( block );
MaskEnables{ idxMaskNames.ShowSParamType } =  ...
get_param( block, 'ShowSParam' );
set_param( block, 'MaskEnables', MaskEnables );
elseif ( strcmp( ContainerShowSParam.Visible, 'on' ) )
ContainerShowSParam.Visible = 'off';



SParamScopeConf = get_param( [ block, '/SParam' ],  ...
'ScopeConfiguration' );
SParamScopeConf.OpenAtSimulationStart = false;
SParamScopeConf.Visible = false;
end 
end 
return 
case 'StartSpectCallback'


hScopeSpec = get_param( [ block, '/SParam' ],  ...
'ScopeSpecificationObject' );
if ~isempty( hScopeSpec )
if isprop( hScopeSpec, 'Scope' ) &&  ...
isprop( hScopeSpec.Scope, 'Visible' ) &&  ...
strcmpi( hScopeSpec.Scope.Visible, 'on' )
hAxes = hScopeSpec.Scope.Framework.Visual.Axes;
if strcmpi( hAxes( 1 ).YLabel.String, 'S-Param (Vrms)' )
hAxes( 1 ).YLabel.String = 'S-param';
end 
end 
end 

case 'AllSParamCallback'
if ( ~isRunningorPaused )
MaskVis = get_param( block, 'MaskVisibilities' );
idxMaskNames = simrfV2getblockmaskparamsindex( block );
if strcmp( get_param( block, 'MeasureAll' ), 'on' )
if ( strcmp( MaskVis{ idxMaskNames.SParamElem }, 'on' ) )
maskObj.getDialogControl(  ...
'SaveButtonContainer' ).Visible = 'on';
maskObj.getDialogControl(  ...
'EmptyText_SParamElem_front' ).Visible =  ...
'off';
maskObj.getDialogControl(  ...
'EmptyText_SParamElem_back' ).Visible =  ...
'off';
MaskVis{ idxMaskNames.SParamElem } = 'off';
set_param( block, 'MaskVisibilities', MaskVis )
end 
elseif ( strcmp( MaskVis{ idxMaskNames.SParamElem }, 'off' ) )
maskObj.getDialogControl(  ...
'SaveButtonContainer' ).Visible = 'off';
maskObj.getDialogControl(  ...
'EmptyText_SParamElem_front' ).Visible = 'on';
maskObj.getDialogControl(  ...
'EmptyText_SParamElem_back' ).Visible = 'on';
MaskVis{ idxMaskNames.SParamElem } = 'on';
set_param( block, 'MaskVisibilities', MaskVis )
end 
end 
return 
case 'CopyCallback'

set_param( [ block, '/Terminate Function' ], 'UserData', [  ] );



SParamTBBlks = find_system( top_sys, 'SearchDepth', '1',  ...
'FollowLinks', 'on', 'LookUnderMasks', 'all',  ...
'Classname', 'tbsparam' );

SParamTBBlks = setdiff( SParamTBBlks, block );
if ~isempty( SParamTBBlks )
VarNames = [ get_param( SParamTBBlks, 'VarName' ); ...
get_param( block, 'VarName' ) ];
LogiVec = [ false( 1, length( VarNames ) - 1 ), true ];
NewVarNames = matlab.lang.makeUniqueStrings(  ...
VarNames, LogiVec );


NewVarName = matlab.lang.makeValidName(  ...
NewVarNames( end  ) );
set_param( block, 'VarName', NewVarName{ 1 } );
end 
return 
case 'PreSaveCallback'
SParamScopeConf = get_param( [ block, '/SParam' ],  ...
'ScopeConfiguration' );
if ~isempty( SParamScopeConf ) &&  ...
isa( SParamScopeConf,  ...
'spbscopes.SpectrumAnalyzerConfiguration' ) &&  ...
isprop( SParamScopeConf, 'SpectrumUnits' )
ShowSParamType = get_param( block, 'ShowSParamType' );
if strcmpi( ShowSParamType, 'Magnitude' )
set_param( block, 'MagSparamUnits',  ...
SParamScopeConf.SpectrumUnits );
else 
set_param( block, 'ReImSparamUnits',  ...
SParamScopeConf.SpectrumUnits );
end 
end 
return 
case 'StartCallback'

set_param( [ block, '/Terminate Function' ], 'UserData', [  ] );
if ~isempty( simrfV2_find_dialog( block ) )
maskObj.getDialogControl( 'SaveButton' ).Enabled = 'off';
end 
return 
case 'StopCallback'
UsrData = get_param( [ block, '/Terminate Function' ],  ...
'UserData' );
if ~isempty( simrfV2_find_dialog( block ) )
ButtonControl = maskObj.getDialogControl( 'SaveButton' );
if ~isfield( UsrData, 'SParamElem' )


ButtonControl.Enabled = 'off';
else 
ButtonControl.Enabled = 'on';
end 
end 
if isfield( UsrData, 'SParamElem' )
freqs = UsrData.Freqs;
NumOfPorts = MaskWSValues.NumOfPorts;
SparaData = NaN( NumOfPorts * NumOfPorts, length( freqs ) );
SparaData( sub2ind( [ NumOfPorts, NumOfPorts ],  ...
UsrData.SParamElem( :, 1 ),  ...
UsrData.SParamElem( :, 2 ) ), : ) = UsrData.SData;
SparamObj = sparameters( reshape( SparaData,  ...
NumOfPorts, NumOfPorts, length( freqs ) ),  ...
freqs, UsrData.Z0 );
assignin( 'base', get_param( block, 'VarName' ), SparamObj );
end 
set_param( block, 'InputIdx', '1' );
return 

case 'SaveButtonCallback'
if ( ~strcmpi( get_param( bdroot( block ),  ...
'BlockDiagramType' ), 'library' ) )
guiTitle =  ...
[ 'Save S-Parametes Measurement From Block ', block ];
UsrData = get_param( [ block, '/Terminate Function' ],  ...
'UserData' );
if isfield( UsrData, 'SParamElem' )
SParamElem = UsrData.SParamElem;
NumOfPorts = round( sqrt( size( SParamElem, 1 ) ) );
if size( SParamElem, 1 ) == NumOfPorts * NumOfPorts
[ fileName, pathName ] = uiputfile( { [ '*.s' ...
, num2str( NumOfPorts ), 'p' ] }, guiTitle,  ...
[ top_sys, '.s', num2str( NumOfPorts ), 'p' ] );


if isequal( fileName, 0 )
return 
end 

write_file = fullfile( pathName, fileName );
freqs = UsrData.Freqs;
SparamObj =  ...
sparameters( reshape( UsrData.SData,  ...
NumOfPorts, NumOfPorts, length( freqs ) ),  ...
freqs, UsrData.Z0 );
rfwrite( SparamObj, write_file );
else 



maskObj.getDialogControl(  ...
'SaveButton' ).Enabled = 'off';
end 
else 


maskObj.getDialogControl(  ...
'SaveButton' ).Enabled = 'off';
end 
end 
return 
case 'AdjustForLargeSigCallback'
MaskVis = get_param( block, 'MaskVisibilities' );
idxMaskNames = simrfV2getblockmaskparamsindex( block );
if strcmp( get_param( block, 'AdjustForLargeSig' ), 'on' )
if strcmp( MaskVis{ idxMaskNames.FoutInput }, 'off' )
maskObj.getDialogControl(  ...
'EmptyText_FoutInput_front' ).Visible = 'on';
MaskVis{ idxMaskNames.FoutInput } = 'on';
maskObj.getDialogControl(  ...
'EmptyText_FoutInput_back' ).Visible = 'on';
set_param( block, 'MaskVisibilities', MaskVis )
end 
elseif strcmp( MaskVis{ idxMaskNames.FoutInput }, 'on' )
maskObj.getDialogControl(  ...
'EmptyText_FoutInput_front' ).Visible = 'off';
MaskVis{ idxMaskNames.FoutInput } = 'off';
maskObj.getDialogControl(  ...
'EmptyText_FoutInput_back' ).Visible = 'off';
set_param( block, 'MaskVisibilities', MaskVis )
end 
return 
case 'SmallSigCallback'
if ~uncheckedIntConf
MaskVis = get_param( block, 'MaskVisibilities' );
idxMaskNames = simrfV2getblockmaskparamsindex( block );
SmallSigDialogControl( block, maskObj, MaskVis,  ...
idxMaskNames );
end 
return 
case 'AllSimFreqsCallback'
if ~uncheckedIntConf
MaskVis = get_param( block, 'MaskVisibilities' );
idxMaskNames = simrfV2getblockmaskparamsindex( block );
SmallSigDialogControl( block, maskObj, MaskVis,  ...
idxMaskNames );
end 
return 
case 'PopFreqsCallback'
if ~uncheckedIntConf
dlg = simrfV2_find_dialog( block );
simrfV2_select_solver_freqs( dlg.getSource );
end 
return 
end 


InstText = maskObj.getDialogControl( 'InstText' );


if ( isRunningorPaused )
suggestionStr1 = 'stop the simulation, ';
suggestionStr2 = ', and run the simulation again';
else 
suggestionStr1 = '';
suggestionStr2 = '';
end 
string_out{ 1 } = [ '1. S-parameter measurement is ' ...
, 'valid only when the Device Under Test (DUT) is ' ...
, 'behaving linearly for the stimulus signal. If the ' ...
, 'stimulus input power is high enough to excite nonlinear ' ...
, 'behavior of the DUT, use the knob to reduce the input ' ...
, 'power amplitude value until the measured S-parameter ' ...
, 'values settle down.\n\n' ];
string_out{ 2 } = [ '2. Any external signals feeding the DUT ' ...
, 'may interfere with the measurement. Any such signals that ' ...
, 'are time varying should be removed from the DUT. External ' ...
, 'steady-state signals that do not vary throughout the ' ...
, 'simulation, are permitted and can be used to bias the DUT ' ...
, 'for linear measurement around a desired operating point. ' ...
, 'If such signals exist, please ', suggestionStr1, 'check ' ...
, 'the ''Adjust for steady-state external signals'' ' ...
, 'checkbox', suggestionStr2, '.\n\n' ];
string_out{ 3 } = [ '3. The S-parameter measurement time is ' ...
, 'finite and any output that the DUT produces after that ' ...
, 'time is not accounted for. If the impulse responses of ' ...
, 'the DUT contain important artifacts beyond the ' ...
, 'measurement time (as shown in the ''Advanced'' tab of ' ...
, 'this dialog box), please ', suggestionStr1, 'increase the ' ...
, 'value specified in ''FFT length'' or reduce the value ' ...
, 'specified in ''Baseband bandwidth'' until the measured ' ...
, 'time is satisfactory', suggestionStr2, '.\n\n' ];
string_out{ 4 } = [ '4. When the impulse responses of the ' ...
, 'DUT do not contain artifacts of importance beyond the ' ...
, 'measurement time, the DUT may still emit some residue ' ...
, 'energy beyond that time. In this case, the residue energy ' ...
, 'from the measurement of one S-parameter may interfere ' ...
, 'with that of another. To avoid that, please ' ...
, suggestionStr1, 'increase the integer value specified in ' ...
, '''Ratio of wait time to measurement time'' until the wait ' ...
, 'time between measurements is long enough', suggestionStr2 ...
, '.\n\n' ];
string_out{ 5 } = [ '5. Other discrepancies between the ' ...
, 'measured S-parameters and those obtained from RF budget ' ...
, 'calculations may originate from the more realistic account ' ...
, 'of the DUT performance obtained using the RF Blockset ' ...
, 'simulation. In this case, verify that the DUT performance ' ...
, 'is evaluated correctly using RF budget calculations. For ' ...
, 'more details, see the documentation.' ];
string_out{ 6 } = '\n';


newInstText = sprintf( cell2mat( string_out ) );
if ( ~strcmp( InstText.Prompt, newInstText ) )
InstText.Prompt = newInstText;
end 
end 

function setChannelNames( block, SParamScopeConf, ShowSParamType, SParamElem )
if strcmpi( ShowSParamType, 'Magnitude' )
if SParamScopeConf.ChannelNames{ 1 }( 1 ) ~= '|'
set_param( block, 'ReImSparamUnits',  ...
SParamScopeConf.SpectrumUnits );
SParamScopeConf.SpectrumUnits =  ...
get_param( block, 'MagSparamUnits' );
end 
for SparamInd = 1:size( SParamElem, 1 )
SParamScopeConf.ChannelNames{ SparamInd } = [ '|S(' ...
, num2str( SParamElem( SparamInd, 1 ) ), ', ' ...
, num2str( SParamElem( SparamInd, 2 ) ), ')|' ];
end 

else 
if SParamScopeConf.ChannelNames{ 1 }( 1 ) == '|'
set_param( block, 'MagSparamUnits',  ...
SParamScopeConf.SpectrumUnits );
SParamScopeConf.SpectrumUnits =  ...
get_param( block, 'ReImSparamUnits' );
end 
for SparamInd = 1:size( SParamElem, 1 )
SParamScopeConf.ChannelNames{ 2 * SparamInd - 1 } = [ 'Re{S(' ...
, num2str( SParamElem( SparamInd, 1 ) ), ', ' ...
, num2str( SParamElem( SparamInd, 2 ) ), ')}' ];
SParamScopeConf.ChannelNames{ 2 * SparamInd } = [ 'Im{S(' ...
, num2str( SParamElem( SparamInd, 1 ) ), ', ' ...
, num2str( SParamElem( SparamInd, 2 ) ), ')}' ];
end 
end 
end 

function res = hasDST
res = builtin( 'license', 'test', 'Signal_Blocks' ) &&  ...
~isempty( ver( 'dsp' ) );
end 

function SmallSigDialogControl( block, maskObj, MaskVis, idxMaskNames )
MaskVisNew = MaskVis;
MaskVisNew( [ idxMaskNames.AllSimFreqs, idxMaskNames.SimFreqs ] ) = { 'off' };
PopFreqContainer = maskObj.getDialogControl( 'PopFreqContainer' );
if strcmp( get_param( block, 'SmallSignalApprox' ), 'on' )
MaskVisNew{ idxMaskNames.AllSimFreqs } = 'on';
if strcmp( MaskVis{ idxMaskNames.AllSimFreqs }, 'off' )


set_param( block, 'MaskVisibilities', MaskVisNew )
end 
if strcmp( get_param( block, 'AllSimFreqs' ), 'off' )
MaskVisNew{ idxMaskNames.SimFreqs } = 'on';
PopFreqContainer.Visible = 'on';
if ~isempty( simrfV2_find_repblk( block, 'Configuration' ) )
UsrDataSolver = get_param( [ block, '/Configuration' ],  ...
'UserData' );
if isfield( UsrDataSolver, 'tones' ) &&  ...
~isempty( UsrDataSolver.tones )
PopFreqContainer.Enabled = 'on';
else 
PopFreqContainer.Enabled = 'off';
end 
end 
else 
PopFreqContainer.Visible = 'off';
end 
else 
PopFreqContainer.Visible = 'off';
end 
if ~all( strcmp( MaskVisNew( [ idxMaskNames.AllSimFreqs ...
, idxMaskNames.SimFreqs ] ), MaskVis( [ idxMaskNames.AllSimFreqs ...
, idxMaskNames.SimFreqs ] ) ) )
set_param( block, 'MaskVisibilities', MaskVisNew );
end 
end 

end 

% Decoded using De-pcode utility v1.2 from file /tmp/tmpeipM6P.p.
% Please follow local copyright laws when handling this file.

