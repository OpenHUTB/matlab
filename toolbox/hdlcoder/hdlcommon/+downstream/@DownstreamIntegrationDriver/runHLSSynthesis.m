function [ status, result ] = runHLSSynthesis( obj )




tool = obj.get( 'Tool' );
result = true;
[ topName, dirName, presentWorkingDir ] = performPreSynthesisTasks( obj.hCodeGen, tool );

if strcmpi( tool, "Cadence Stratus" )
try 
synCmd = "make sim_V_SLOW";
[ ~, result ] = system( synCmd );

if ~isempty( result ) && ( contains( result, 'TEST COMPLETED (PASSED)' ) || contains( result, 'SIMULATION PASSED' ) )
status = 1;
else 
status = 0;
end 

catch me %#ok<NASGU>
status = 0;
end 

elseif strcmpi( tool, "Xilinx Vitis HLS" )
try 
[ ~, hA ] = obj.hAvailableToolList.isInToolList( obj.getToolName );
vitisHLSPrjName = hA.AvailablePlugin.ProjectDir;

obj.generateVitisProjectTclFile( vitisHLSPrjName, 'synthesis' );
synCmd = "vitis_hls syn_script.tcl";

[ ~, result ] = system( synCmd );

if ~isempty( result ) && ~contains( result, 'ERROR:' )
status = 1;
else 
status = 0;
end 

catch me %#ok<NASGU>
status = 0;
end 

else 


error( message( 'hdlcoder:workflow:InvalidHLSTool', tool ) );
end 

performPostSynthesisTasks( result, topName, dirName, presentWorkingDir );
end 

function [ topName, dirName, presentWorkingDir ] = performPreSynthesisTasks( cgInfo, tool )
dirName = cgInfo.CodegenDir;
topName = cgInfo.EntityTop;
presentWorkingDir = pwd;

if strcmpi( tool, 'Cadence Stratus' )
stratusPrjDir = 'stratus_prj';
dirName = fullfile( dirName, stratusPrjDir );
end 

try 
cd( dirName );
catch me
error( message( 'Coder:hdl:invalid_directory', dirName ) );
end 

if strcmpi( tool, 'Cadence Stratus' )
prjFile = 'project.tcl';
if ~exist( prjFile, 'file' )
hdldisp( message( 'hdlcoder:hdldisp:SynthProjectFailure' ) );
end 

elseif strcmpi( tool, 'Xilinx Vitis HLS' )
cmd_openTargetTool = sprintf( "openVitisHLSPrj('%s')", dirName );
prjLink = sprintf( '<a href="matlab:downstream.DownstreamIntegrationDriver.%s"> %s </a>',  ...
cmd_openTargetTool, dirName );

msg = message( 'hdlcoder:workflow:GeneratingProject', tool, prjLink );
hdldisp( msg );
end 
end 

function performPostSynthesisTasks( result, topName, dirName, presentWorkingDir )
synResultsFileName = [ topName, '_syn_results.txt' ];
fid = fopen( synResultsFileName, 'w' );
if fid ==  - 1
error( message( 'hdlcoder:matlabhdlcoder:openfile', synResultsFileName ) );
end 
fprintf( fid, '%s', result );
fclose( fid );

hdldisp( message( 'hdlcoder:hdldisp:SynthGenReport', hdlgetfilelink( fullfile( dirName, synResultsFileName ) ) ) );
cd( presentWorkingDir );
end 

% Decoded using De-pcode utility v1.2 from file /tmp/tmpv5qngi.p.
% Please follow local copyright laws when handling this file.

