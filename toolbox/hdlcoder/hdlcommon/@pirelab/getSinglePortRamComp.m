function [ RamNet, RamNetInstance ] = getSinglePortRamComp( hN, hInSignals, hOutSignals,  ...
compName, numBanks, readNewData, simulinkHandle, initialVal, RAMDirective )










narginchk( 3, 9 );

if nargin < 9 || isempty( RAMDirective )
RAMDirective = '';
end 

if nargin < 8 || isempty( initialVal )
initialVal = '';
end 

if nargin < 7 || isempty( simulinkHandle )
simulinkHandle =  - 1;
end 
if nargin < 6
readNewData = 1;
end 
if nargin < 5
numBanks = 1;
end 
if nargin < 4 || isempty( compName )
compName = 'singlePortRam';
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
else 

hWriteAddrDemuxOutSignals = hInSignals( 2 );
hWriteEnDemuxOutSignals = hInSignals( 3 );
end 
else 

hWriteDataDemuxOutSignals = hInSignals( 1 );
hWriteAddrDemuxOutSignals = hInSignals( 2 );
hWriteEnDemuxOutSignals = hInSignals( 3 );
end 



hD = hdlcurrentdriver;
if ~isempty( hD )
ramDescriptor = createRAMDescriptor( hD, hN, readNewData, hInSignals,  ...
hOutSignals, initialVal, RAMDirective );
RamNet = hD.getRamNetworkFromMap( ramDescriptor, [  ] );
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
bankOutSignals = hOutSignals;
else 
bankOutSignals = hN.addSignal( scalarOutType, 'pre_rd_out' );
bankOutSignals.SimulinkRate = hOutSignals( 1 ).SimulinkRate;
end 

allBanksReadOutSignals( nn ) = bankOutSignals;

if ~isUsingScalarExpansion
bankInSignals = [ hWriteDataDemuxOutSignals( nn ), hWriteAddrDemuxOutSignals( nn ),  ...
hWriteEnDemuxOutSignals( nn ) ];
else 
bankInSignals = [ hWriteDataDemuxOutSignals( nn ), hWriteAddrDemuxOutSignals,  ...
hWriteEnDemuxOutSignals ];
end 

[ RamNet, RamNetInstance ] = pircore.getSinglePortRamComp( hN, bankInSignals,  ...
bankOutSignals, compName, numBanks, nn - 1, readNewData, simulinkHandle,  ...
RamNet, needWrapper, initialVal, RAMDirective );
if ~isempty( hD )
hD.saveRamNetworkToMap( ramDescriptor, RamNet );
end 
end 

if numBanks > 1
pirelab.getMuxComp( hN, allBanksReadOutSignals, hOutSignals, 'rd_out_concat' );
end 

end 


function ramDescriptor = createRAMDescriptor( hD, hN, readNewData, hInSignals,  ...
hOutSignals, initialVal, RAMDirective )
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
ramDescriptor = sprintf( 'single_%d_%d_%d_%s_%g%s%s%s',  ...
readNewData, isComplex, singlebit, signs,  ...
hInSignals( 1 ).SimulinkRate, hN.getCtxName, ivstr, RAMDirective );
end 

% Decoded using De-pcode utility v1.2 from file /tmp/tmpWDYChF.p.
% Please follow local copyright laws when handling this file.

