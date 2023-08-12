function socLoadExampleBitstream( hw, modelName )












demoModels = {  ...
'soc_ADSB',  ...
'soc_hwsw_stream_top',  ...
'soc_image_rotation',  ...
'soc_memory_traffic_generator',  ...
'soc_rfcapture',  ...
 };
modelName = validatestring( modelName, demoModels );
boardId = soc.internal.getBoardID( hw.BoardName );

if any( strcmpi( boardId, { 'a10soc', 'c5soc' } ) )
bitFileDir = fullfile( matlabroot, 'toolbox', 'soc', 'supportpackages', 'intelsoc', 'intelsocexamples', 'bitstreams' );
else 
bitFileDir = fullfile( matlabroot, 'toolbox', 'soc', 'supportpackages', 'xilinxsoc', 'xilinxsocexamples', 'bitstreams' );
end 
bitFile = fullfile( bitFileDir, [ modelName, '-', boardId ] );
matFile = fullfile( bitFileDir, [ modelName, '_socsysinfo-', boardId, '.mat' ] );


i_programSOC( hw, bitFile, matFile );
end 


function i_programSOC( hw, bitFile, matFile )
info = load( matFile );
sysinfo = info.socsysinfo;
hasProcessor = {  ...
'Xilinx Zynq ZC706 evaluation kit',  ...
'ZedBoard',  ...
'Xilinx Zynq UltraScale+ MPSoC ZCU102 Evaluation Kit' ...
, 'Altera Cyclone V SoC development kit',  ...
'Altera Arria 10 SoC development kit' ...
 };
if ismember( hw.BoardName, hasProcessor )

sysinfo.projectinfo.prj_dir = tempname;
deviceTreeGenObj = soc.if.CustomDeviceTreeUpdater.getInstance( sysinfo, 'HardwareObject', hw );
dtbFile = generateDeviceTree( deviceTreeGenObj );
loadBitstream( hw, bitFile, dtbFile );
else 

jtagChainPosition = soc.internal.getJTAGChainPosition( hw.BoardName );
soc.internal.programFPGA( 'Xilinx', bitFile, jtagChainPosition );
end 
end 
% Decoded using De-pcode utility v1.2 from file /tmp/tmpcum1z1.p.
% Please follow local copyright laws when handling this file.

