classdef ( Abstract )Target < handle





















properties ( GetAccess = public, SetAccess = immutable )

Vendor = '';
end 

properties ( Abstract, Constant )

Interface dlhdl.TargetInterface
end 

properties ( Abstract, Access = protected )

DefaultProgrammingMethod hdlcoder.ProgrammingMethod
end 

properties ( Access = protected )

hFPGA


BitstreamChecksum = '';
end 

properties ( Constant, Hidden = true )
ExampleStr = 'hTarget = dlhdl.Target(''Xilinx'')'
end 


properties ( GetAccess = public, SetAccess = protected, Hidden )
TargetID = '';
end 

properties ( Access = private )
UseTargetManager = dnnfpgafeature( 'UseTargetManager' )
end 


methods ( Static, Hidden )
function obj = getInstance( vendor, varargin )

if nargin < 1
error( message( 'dnnfpga:workflow:TargetWrongInput', dnnfpga.hardware.Target.ExampleStr ) );
end 





p = inputParser;
p.KeepUnmatched = true;
p.addParameter( 'Interface', dlhdl.TargetInterface.JTAG, @( s )( ischar( s ) ) || isstring( s ) || isa( s, 'dlhdl.TargetInterface' ) );
p.parse( varargin{ : } );
interface = p.Results.Interface;




if isa( vendor, 'fpga' )
interface = dlhdl.TargetInterface.Custom;
else 
interface = dlhdl.TargetInterface( interface );
end 


extraArgs = namedargs2cell( p.Unmatched );

switch interface
case dlhdl.TargetInterface.JTAG
obj = dnnfpga.hardware.TargetJTAG( vendor, extraArgs{ : } );
case dlhdl.TargetInterface.PCIe
error( message( 'dnnfpga:workflow:UnsupportedHardwareInterface', char( interface ) ) );
case dlhdl.TargetInterface.Ethernet
obj = dnnfpga.hardware.TargetEthernet( vendor, extraArgs{ : } );
case dlhdl.TargetInterface.File
obj = dnnfpga.hardware.TargetFile( vendor, extraArgs{ : } );
case dlhdl.TargetInterface.Custom
hFPGA = vendor;
obj = dnnfpga.hardware.TargetCustom( hFPGA, extraArgs{ : } );
otherwise 
error( message( 'dnnfpga:workflow:UnsupportedHardwareInterface', char( interface ) ) );
end 
end 
end 

methods ( Access = protected )
function obj = Target( vendor )
vendor = convertStringsToChars( vendor );

if ~ischar( vendor )
error( message( 'dnnfpga:workflow:TargetWrongInput', obj.ExampleStr ) );
end 

try 
switch lower( vendor )
case 'xilinx'
dnnfpga.validateDLSupportPackage( 'Xilinx', 'Target' );
obj.Vendor = 'Xilinx';
case 'intel'
dnnfpga.validateDLSupportPackage( 'Intel', 'Target' );
obj.Vendor = 'Intel';
otherwise 
error( message( 'dnnfpga:workflow:InvalidVendor', vendor, strjoin( { 'Xilinx', 'Intel' }, ', ' ) ) );
end 
catch ME
throwAsCaller( ME );
end 


obj.registerTarget;
end 
end 


methods ( Access = public )
function release( obj )

if ~isempty( obj.hFPGA )
release( obj.hFPGA );
end 
end 

function delete( obj )

obj.release;

obj.unregisterTarget;
end 

function validateConnection( obj )
try 

dnnfpga.disp( message( 'dnnfpga:workflow:ValidateBitstreamConnection', char( obj.Interface ) ) );
try 
obj.validateBitstreamConnection(  );
catch ME

if strcmp( ME.identifier, 'dnnfpga:workflow:NoConnectionToBitstream' )
obj.warningWithoutStack( message( 'dnnfpga:workflow:ValidateBitstreamConnectionFailure', char( obj.Interface ), ME.message ) );
return ;
else 
rethrow( ME );
end 
end 
dnnfpga.disp( message( 'dnnfpga:workflow:ValidBitstreamConnection', char( obj.Interface ) ) );
catch ME
ME_new = obj.getTroubleshootingException( ME );
throw( ME_new );
end 
end 
end 


methods ( Access = public, Hidden = true )

function programBitstream( obj, hBitstream, programMethod )



R36
obj
hBitstream dnnfpga.bitstream.Bitstream
programMethod hdlcoder.ProgrammingMethod = obj.DefaultProgrammingMethod;
end 



obj.validateVendor( hBitstream );
obj.validateInterface( hBitstream );


hBitstream.validateProgrammingMethod( programMethod );


bitstreamPath = hBitstream.getAbsolutePath(  );
if ~isfile( bitstreamPath )
error( message( 'hdlcommon:workflow:NoBitFileWithName', bitstreamPath ) );
end 

switch programMethod
case hdlcoder.ProgrammingMethod.JTAG
obj.programBitstreamJTAG( hBitstream );
case hdlcoder.ProgrammingMethod.Download
obj.programBitstreamDownload( hBitstream );
case hdlcoder.ProgrammingMethod.Custom
obj.programBitstreamCustom( hBitstream );
otherwise 
error( message( 'dnnfpga:workflow:UnsupportedProgrammingMethod', char( programMethod ) ) );
end 
end 


function connectToBitstream( obj, hBitstream )


obj.validateVendor( hBitstream );
obj.validateInterface( hBitstream );

try 
obj.establishBitstreamConnection( hBitstream );
catch ME
ME_new = obj.getTroubleshootingException( ME );
throw( ME_new );
end 
end 


function writeMemory( obj, addr, data )
obj.hFPGA.writeMemory( addr, data );
end 

function data = readMemory( obj, addr, len, varargin )
data = obj.hFPGA.readMemory( addr, len, varargin{ : } );
end 
end 

methods ( Access = protected )

function programBitstreamJTAG( obj, hBitstream )
bitstreamPath = hBitstream.getAbsolutePath(  );
jtagChainPos = hBitstream.getJTAGChainPosition(  );
obj.hFPGA.programFPGA( bitstreamPath, jtagChainPos );
end 

function programBitstreamCustom( obj, hBitstream )

customProgFcn = hBitstream.getCustomProgrammingFcn;
error( message( 'dnnfpga:workflow:ProgMethodUnsupported' ) );

end 


function establishBitstreamConnection( obj, hBitstream )



checksumNew = hBitstream.getChecksum;
if ~isequal( obj.BitstreamChecksum, checksumNew )
obj.release;
obj.resetFPGAObject;
end 



if obj.isFPGAObjectConfiguredForBitstream( hBitstream )








if ~obj.isBitstreamConnectionValid
obj.release;
obj.validateBitstreamConnection;
end 
else 


try 
obj.configureFPGAObjectForBitstream( hBitstream );
catch ME
msg = MException( message( 'dnnfpga:workflow:BitstreamConnectionFailure' ) );
msg = msg.addCause( ME );
throw( msg );
end 




obj.BitstreamChecksum = checksumNew;



try 
obj.validateBitstreamConnection;
catch ME
obj.release;
rethrow( ME );
end 
end 
end 

function resetFPGAObject( obj )

obj.hFPGA.removeInterface;
end 

function isConfigured = isFPGAObjectConfiguredForBitstream( obj, hBitstream )


isConfigured = true;
try 
obj.validateFPGAObjectConfigurationForBitstream( hBitstream );
catch 
isConfigured = false;
return ;
end 
end 

function validateFPGAObjectConfigurationForBitstream( obj, hBitstream )
obj.validateFPGAObject( obj.hFPGA );








obj.getDeepLearningProcessorFPGAInterface( hBitstream );
obj.getDeepLearningMemoryFPGAInterface( hBitstream );
end 

function getDeepLearningProcessorFPGAInterface( obj, hBitstream )
[ procBaseAddr, procAddrRange ] = hBitstream.getDLProcessorAddressSpace;




hInterface = obj.hFPGA.getInterfaceForAddr( procBaseAddr );



if ~hInterface.isAddressInRange( procBaseAddr, procAddrRange - 1 )
error( 'FPGA interface has address space with base address 0x%s and address range 0x%s, which does not fit deep learning processor address space with base address 0x%s and address range 0x%s.',  ...
dec2hex( hInterface.BaseAddress ), dec2hex( hInterface.AddressRange ), dec2hex( procBaseAddr ), dec2hex( procAddrRange ) );
end 


if ~fpgaio.FPGA.isAXI4SlaveInterface( hInterface )
error( 'FPGA interface for deep learning processor must be of type "AXI4Slave".' );
end 
end 

function getDeepLearningMemoryFPGAInterface( obj, hBitstream )
[ memBaseAddr, memAddrRange ] = hBitstream.getDLMemoryAddressSpace;




hInterface = obj.hFPGA.getInterfaceForAddr( memBaseAddr );



if ~hInterface.isAddressInRange( memBaseAddr, memAddrRange - 1 )
error( 'FPGA interface has address space with base address 0x%s and address range 0x%s, which does not fit deep learning memory address space with base address 0x%s and address range 0x%s.',  ...
dec2hex( hInterface.BaseAddress ), dec2hex( hInterface.AddressRange ), dec2hex( memBaseAddr ), dec2hex( memAddrRange ) );
end 


if ~fpgaio.FPGA.isMemoryInterface( hInterface )
error( 'FPGA interface for deep learning memory must be of type "Memory".' );
end 
end 

function [ isValid, errorMsg ] = isBitstreamConnectionValid( obj )
isValid = true;
errorMsg = '';

try 
obj.validateBitstreamConnection;
catch ME
isValid = false;
errorMsg = ME.message;
end 
end 

function validateBitstreamConnection( obj )




if isempty( obj.BitstreamChecksum )


error( message( 'dnnfpga:workflow:NoConnectionToBitstream' ) );
end 



isValid = true;
try 




obj.readMemory( obj.hFPGA.Interfaces( 1 ).BaseAddress, 1 );
obj.readMemory( obj.hFPGA.Interfaces( 2 ).BaseAddress, 1 );
catch ME
isValid = false;
errorMsg = ME.message;
end 

if ~isValid
msg = message( 'dnnfpga:workflow:InvalidBitstreamConnection', errorMsg );
throw( MException( msg ) );
end 


end 

function addAXI4SlaveInterface( obj, interfaceID, baseAddr, addrRange, hWriteDriver, hReadDriver, driverAddrMode )


obj.hFPGA.addAXI4SlaveInterface(  ...
"InterfaceID", interfaceID,  ...
"BaseAddress", baseAddr,  ...
"AddressRange", addrRange,  ...
"WriteDriver", hWriteDriver,  ...
"ReadDriver", hReadDriver,  ...
"DriverAddressMode", driverAddrMode );
end 

function addMemoryInterface( obj, interfaceID, baseAddr, addrRange, hWriteDriver, hReadDriver, driverAddrMode )


obj.hFPGA.addMemoryInterface(  ...
"InterfaceID", interfaceID,  ...
"BaseAddress", baseAddr,  ...
"AddressRange", addrRange,  ...
"WriteDriver", hWriteDriver,  ...
"ReadDriver", hReadDriver,  ...
"DriverAddressMode", driverAddrMode );
end 
end 

methods ( Abstract, Access = protected )



configureFPGAObjectForBitstream( obj, hBitstream )
end 


methods ( Access = protected )
function validateVendor( obj, hBitstream )

bitstreamVendor = hBitstream.getVendorName;
if ~strcmpi( obj.Vendor, bitstreamVendor )
error( message( 'dnnfpga:workflow:InvalidVendorBitstream', obj.Vendor, bitstreamVendor ) );
end 
end 

function validateInterface( obj, hBitstream )

hBitstream.validateHWInterface( obj.Interface );
end 
end 

methods ( Static, Access = protected )
function validateFPGAObject( hFPGA )





if ~isa( hFPGA, 'fpga' )
error( 'Invalid input for FPGA object. It must be of class "fpga".' );
end 

if isempty( hFPGA.Interfaces )
error( 'FPGA object must have at least one AXI4 Slave interface and one Memory interface.' );
end 

hasAXI4SlaveInterface = any( fpgaio.FPGA.isAXI4SlaveInterface( hFPGA.Interfaces ) );
hasMemoryInterface = any( fpgaio.FPGA.isMemoryInterface( hFPGA.Interfaces ) );
if ~hasAXI4SlaveInterface || ~hasMemoryInterface
error( 'FPGA object must have at least one AXI4 Slave interface and one Memory interface.' );
end 
end 
end 


methods ( Access = protected )
function docLink = getTroubleshootingDocLink( obj )
switch lower( obj.Vendor )
case 'xilinx'
anchorID = 'dlhdl_xilinx_setupand_configuration';
spID = 'xilinx';
case 'intel'
anchorID = 'dlhdl_intel_setupand_configuration';
spID = 'intel';
end 

docLink = dnnfpga.tool.getDocLink( anchorID, message( 'dnnfpga:workflow:Troubleshooting' ), spID );
end 

function ME_new = getTroubleshootingException( obj, ME_orig )

docLink = obj.getTroubleshootingDocLink;
ME_new = MException( message( 'dnnfpga:workflow:TroubleshootConnection', ME_orig.message, docLink ) );


for ii = 1:length( ME_orig.cause )
ME_new = ME_new.addCause( ME_orig.cause{ ii } );
end 
end 
end 

methods ( Static, Access = protected )
function warningWithoutStack( msg )



warnState = warning( 'query', 'backtrace' );

warning( 'off', 'backtrace' );

warning( msg );

warning( warnState );
end 
end 


methods ( Access = private )
function registerTarget( obj )
if obj.UseTargetManager
obj.TargetID = dnnfpga.hardware.TargetManager.getNewTargetID( obj.Vendor );
dnnfpga.hardware.TargetManager.addTargetStatic( obj );
end 
end 

function unregisterTarget( obj )
if obj.UseTargetManager
dnnfpga.hardware.TargetManager.removeTargetStatic( obj );
end 
end 
end 

methods ( Static, Hidden = true )
function releaseAllTargets(  )
dnnfpga.hardware.TargetManager.releaseAllTargets;
end 
end 

end 




% Decoded using De-pcode utility v1.2 from file /tmp/tmp40rJfp.p.
% Please follow local copyright laws when handling this file.

