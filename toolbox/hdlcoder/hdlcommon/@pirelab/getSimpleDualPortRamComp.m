function [ RamNet, RamNetInstance ] = getSimpleDualPortRamComp( hN, hInSignals,  ...
hOutSignals, compName, numBanks, simulinkHandle, RamNet, ramCorePrefix, initialVal, RAMDirective )




narginchk( 3, 10 );

if nargin < 10 || isempty( RAMDirective )
RAMDirective = '';
end 

if nargin < 9 || isempty( initialVal )
initialVal = '';
end 

if nargin < 8

ramCorePrefix = '';
end 

if nargin < 7
RamNet = [  ];
end 

if nargin < 6 || isempty( simulinkHandle )
simulinkHandle =  - 1;
end 

if nargin < 5
if hInSignals( 1 ).Type.isArrayType
numBanks = hInSignals( 1 ).Type.Dimensions;
else 
numBanks = 1;
end 
end 



if nargin < 4 || isempty( compName )
compName = 'simpleDualPortRam';
end 



addrType = hInSignals( 2 ).Type;
initialVal = pirelab.convertRAMIV2Str( initialVal, addrType );
if strcmp( initialVal, '0' )
initialVal = '';
end 


if hOutSignals.SimulinkRate == 0
hOutSignals.SimulinkRate = hInSignals( 1 ).SimulinkRate;
end 

isUsingScalarExpansion = false;

if numBanks > 1
writeDataDemuxComp = pirelab.getDemuxCompOnInput( hN, hInSignals( 1 ) );
hWriteDataDemuxOutSignals = writeDataDemuxComp.PirOutputSignals;

isUsingScalarExpansion = ~hInSignals( 2 ).Type.isArrayType;

if ~isUsingScalarExpansion

writeAddrDemuxComp = pirelab.getDemuxCompOnInput( hN, hInSignals( 2 ) );
hWriteAddrDemuxOutSignals = writeAddrDemuxComp.PirOutputSignals;

writeEnDemuxComp = pirelab.getDemuxCompOnInput( hN, hInSignals( 3 ) );
hWriteEnDemuxOutSignals = writeEnDemuxComp.PirOutputSignals;

readAddrDemuxComp = pirelab.getDemuxCompOnInput( hN, hInSignals( 4 ) );
hReadAddrDemuxOutSignals = readAddrDemuxComp.PirOutputSignals;
else 

hWriteAddrDemuxOutSignals = hInSignals( 2 );
hWriteEnDemuxOutSignals = hInSignals( 3 );
hReadAddrDemuxOutSignals = hInSignals( 4 );
end 
else 

hWriteDataDemuxOutSignals = hInSignals( 1 );
hWriteAddrDemuxOutSignals = hInSignals( 2 );
hWriteEnDemuxOutSignals = hInSignals( 3 );
hReadAddrDemuxOutSignals = hInSignals( 4 );
end 



hD = hdlcurrentdriver;
if ~isempty( hD )
ramDescriptor = createRAMDescriptor( hD, hN, hInSignals, hOutSignals,  ...
ramCorePrefix, initialVal, RAMDirective );
RamNet = hD.getRamNetworkFromMap( ramDescriptor, RamNet );
needWrapper = hD.getParameter( 'ramarchitecture' ) ~= 1;
if needWrapper
compName = [ compName, '_Wrapper' ];
end 
else 
RamNet = [  ];
needWrapper = false;
end 
allBanksReadOutSignals = hdlhandles( 1, numBanks );
[ ~, scalarOutType ] = pirelab.getVectorTypeInfo( hOutSignals );
for nn = 1:numBanks




if numBanks == 1
bankOutSignals = deal( hOutSignals );
else 
bankOutSignals = hN.addSignal( scalarOutType, 'pre_rd_out' );
bankOutSignals.SimulinkRate = hOutSignals( 1 ).SimulinkRate;
end 

allBanksReadOutSignals( nn ) = bankOutSignals;

if ~isUsingScalarExpansion
bankInSignals = [ hWriteDataDemuxOutSignals( nn ), hWriteAddrDemuxOutSignals( nn ),  ...
hWriteEnDemuxOutSignals( nn ), hReadAddrDemuxOutSignals( nn ) ];
else 
bankInSignals = [ hWriteDataDemuxOutSignals( nn ), hWriteAddrDemuxOutSignals,  ...
hWriteEnDemuxOutSignals, hReadAddrDemuxOutSignals ];
end 
[ RamNet, RamNetInstance ] = pircore.getSimpleDualPortRamComp( hN,  ...
bankInSignals, bankOutSignals, compName, numBanks, nn - 1,  ...
simulinkHandle, RamNet, ramCorePrefix, needWrapper, initialVal, RAMDirective );
if ~isempty( hD )
hD.saveRamNetworkToMap( ramDescriptor, RamNet );
end 
end 

if numBanks > 1
pirelab.getMuxComp( hN, allBanksReadOutSignals, hOutSignals, 'rd_out_concat' );
end 
end 


function ramDescriptor = createRAMDescriptor( hD, hN, hInSignals, hOutSignals,  ...
ramCorePrefix, initialVal, RAMDirective )
if hInSignals( 1 ).Type.getLeafType.WordLength == 1
singlebit = true;
else 
singlebit = false;
end 
signs = '';
inputStyle = hD.getParameter( 'filter_input_type_std_logic' );
if inputStyle ~= 1
if hInSignals( 1 ).Type.getLeafType.Signed
signs = [ signs, 's' ];
else 
signs = [ signs, 'u' ];
end 
if hInSignals( 2 ).Type.getLeafType.Signed
signs = [ signs, 's' ];
else 
signs = [ signs, 'u' ];
end 
if hInSignals( 4 ).Type.getLeafType.Signed
signs = [ signs, 's' ];
else 
signs = [ signs, 'u' ];
end 
end 
outputStyle = hD.getParameter( 'filter_output_type_std_logic' );
if outputStyle ~= 1
if hOutSignals( 1 ).Type.getLeafType.Signed
signs = [ signs, 's' ];
else 
signs = [ signs, 'u' ];
end 
end 
isComplex = hInSignals( 1 ).Type.isComplexType ||  ...
hInSignals( 1 ).Type.BaseType.isComplexType;


if ~isempty( initialVal )
ivstr = num2str( rand( 1 ), 10 );
else 
ivstr = '';
end 
ramDescriptor = sprintf( '%ssimpledual_%d_%d_%s%g%s%s%s',  ...
ramCorePrefix, isComplex, singlebit, signs,  ...
hInSignals( 1 ).SimulinkRate, hN.getCtxName, ivstr, RAMDirective );
end 



% Decoded using De-pcode utility v1.2 from file /tmp/tmpZJuLGC.p.
% Please follow local copyright laws when handling this file.

