function adeinfo2msaMain( runType, runNumber, testName, simulationType, fileName, launchMSA, metricsOnlyExtract )

























R36
runType = 'Interactive'
runNumber = 1
testName = 'Test'
simulationType = 'all'
fileName = 'adeInfo.mat'
launchMSA = true
metricsOnlyExtract = false
end 



import cadence.srrdata.*
import cadence.Query.*
import cadence.utils.*
import cadence.simdata.*
import cadence.srrsata.*
import cadence.streamCalculator.*
import cadence.utils.cdsPlot.*


if nargin < 4
try 


adeInfo = evalin( 'base', 'adeInfo.loadResult' );

runDetails = split( adeInfo.adeHistory, '.' );
runType = runDetails{ 1 };
runNumber = str2double( runDetails{ 2 } );
testName = evalin( 'base', 'adeInfo.adeRDB.tests.Test{1}' );

if ( metricsOnlyExtract )
fileName = [ testName, '_', runType, '_', num2str( runNumber ), '_metricsOnly', '.mat' ];
else 
fileName = [ testName, '_', runType, '_', num2str( runNumber ), '.mat' ];
end 
s1 = runType;
s2 = runNumber;
s3 = testName;
warning( 'off', 'MATLAB:class:DestructorError' );
adeInfo.loadResult( 'test', s3, 'DataPoint',  - 1 );
catch 
error( message( 'msblks:mixedsignalanalyzer:AdeInfoSpecificInput2' ) );
end 
end 










s3 = testName;
if ( isempty( s3 ) )


adeInfo = evalin( 'base', 'adeInfo.loadResult' );



testName = evalin( 'base', 'adeInfo.adeRDB.tests.Test{1}' );
s3 = testName;
end 

s1 = runType;
s2 = runNumber;
s3 = testName;




disp( 'Extracting simulation data...' );

simDBS = [  ];
simDBC = [  ];





[ ~, ~ ] = evalc( "cadence.AdeInfoManager.loadResult('test', s3, 'history',[s1 '.' s2],'DataPoint',-1);" );

[ ~, rdb ] = evalc( "cadence.AdeInfoManager.loadResult('test',s3,'history',[s1 '.' s2]).adeRDB;" );
[ ~, dbTables ] = evalc( "rdb.query();" );



[ ~, signalTables ] = evalc( 'rdb.where(Type == TypeValue.Signal).query();' );
[ ~, exprTables ] = evalc( 'rdb.where(Type == TypeValue.Expr).query();' );

warning( 'on', 'MATLAB:class:DestructorError' );;


dbTables( ~strcmpi( dbTables.Test, s3 ), : ) = [  ];

totalCorners = rdb.corners;
paramTable = rdb.params;
paramConditionTable = rdb.paramConditions;




iscell_dbTablesResult = iscell( dbTables.Result );
iscell_dbTablesCorner = iscell( dbTables.Corner );
iscell_dbTablesOutput = iscell( dbTables.Output );








initialSize = length( dbTables.Result );
results.no{ initialSize } = [  ];
corners.no{ initialSize } = [  ];
output.no{ initialSize } = [  ];
sValue.no{ initialSize } = [  ];
sCorners.no{ initialSize } = [  ];
sScalar.no{ initialSize } = [  ];




wResultsCornersOutputLastUsedIndex = 0;
sValueCornersScalarLastUsedIndex = 0;






[ ~, simDBS ] = evalc( "struct(cadence.AdeInfoManager.loadResult('test',s3))" );

if ( ~metricsOnlyExtract )

signalAlias = msblks.internal.cadence2matlab.findSignalAlias;
uniqueOutputs = unique( dbTables.Output );

waveformData = [  ];
waveformDataTemp = [  ];
NodeWithissue = [  ];
flag = 0;
for i = 1:length( uniqueOutputs )

if ( ismember( uniqueOutputs{ i }, signalAlias.Name ) )
[ ~, idx ] = ismember( uniqueOutputs{ i }, signalAlias.Name );
try 
signalName = signalAlias.Output{ idx };
catch 
signalName = uniqueOutputs{ i };
end 
else 
signalName = uniqueOutputs{ i };
end 
if ( ~isempty( exprTables ) )
if ( ~ismember( uniqueOutputs{ i }, exprTables.Output ) )


for wfType = 1:10
switch wfType
case 1
waveform = getWaveform( 'VT', signalName );
if ( ~isempty( waveform ) )
if ( flag == 0 )
flag = 1;
end 
end 
case 2
waveform = getWaveform( 'VS', signalName );
if ( ~isempty( waveform ) )
if ( flag == 0 )
flag = 1;
end 
end 
case 3
waveform = getWaveform( 'VDC', signalName );
if ( ~isempty( waveform ) )
if ( flag == 0 )
flag = 1;
end 
end 
case 4
waveform = getWaveform( 'VF', signalName );
if ( ~isempty( waveform ) )
if ( flag == 0 )
flag = 1;
end 
end 
case 5
waveform = getWaveform( 'IF', signalName );
if ( ~isempty( waveform ) )
if ( flag == 0 )
flag = 1;
end 
end 
case 6
waveform = getWaveform( 'IS', signalName );
if ( ~isempty( waveform ) )
if ( flag == 0 )
flag = 1;
end 
end 
case 7
waveform = getWaveform( 'IDC', signalName );
if ( ~isempty( waveform ) )
if ( flag == 0 )
flag = 1;
end 
end 
case 8
waveform = getWaveform( 'IT', signalName );
if ( ~isempty( waveform ) )
if ( flag == 0 )
flag = 1;
end 
end 
case 9
waveform = getWaveform( 'VN', signalName );
if ( ~isempty( waveform ) )
if ( flag == 0 )
flag = 1;
end 
end 
case 10
waveform = getWaveform( 'NG', signalName );
if ( ~isempty( waveform ) )
if ( flag == 0 )
flag = 1;
end 
end 
otherwise 
waveform = [  ];
end 


if ~isempty( waveform )
if ( istable( waveform ) )
if ( isempty( waveformDataTemp ) )
waveformDataTemp = waveform;
else 
waveformDataTemp = [ waveformDataTemp;waveform ];
end 
else 
flag = 0;
end 
end 


end 
if ( flag == 0 )
if ( isempty( NodeWithissue ) )
NodeWithissue = { uniqueOutputs{ i } };
else 
NodeWithissue( end  + 1 ) = { uniqueOutputs{ i } };
end 
else 
flag = 0;
end 
end 
else 
for wfType = 1:10
switch wfType
case 1
waveform = getWaveform( 'VT', signalName );
if ( ~isempty( waveform ) )
if ( flag == 0 )
flag = 1;
end 
end 
case 2
waveform = getWaveform( 'VS', signalName );
if ( ~isempty( waveform ) )
if ( flag == 0 )
flag = 1;
end 
end 
case 3
waveform = getWaveform( 'VDC', signalName );
if ( ~isempty( waveform ) )
if ( flag == 0 )
flag = 1;
end 
end 
case 4
waveform = getWaveform( 'VF', signalName );
if ( ~isempty( waveform ) )
if ( flag == 0 )
flag = 1;
end 
end 
case 5
waveform = getWaveform( 'IF', signalName );
if ( ~isempty( waveform ) )
if ( flag == 0 )
flag = 1;
end 
end 
case 6
waveform = getWaveform( 'IS', signalName );
if ( ~isempty( waveform ) )
if ( flag == 0 )
flag = 1;
end 
end 
case 7
waveform = getWaveform( 'IDC', signalName );
if ( ~isempty( waveform ) )
if ( flag == 0 )
flag = 1;
end 
end 
case 8
waveform = getWaveform( 'IT', signalName );
if ( ~isempty( waveform ) )
if ( flag == 0 )
flag = 1;
end 
end 
case 9
waveform = getWaveform( 'VN', signalName );
if ( ~isempty( waveform ) )
if ( flag == 0 )
flag = 1;
end 
end 
case 10
waveform = getWaveform( 'NG', signalName );
if ( ~isempty( waveform ) )
if ( flag == 0 )
flag = 1;
end 
end 
otherwise 
waveform = [  ];
end 



if ~isempty( waveform )
if ( istable( waveform ) )
if ( isempty( waveformDataTemp ) )
waveformDataTemp = waveform;
else 
waveformDataTemp = [ waveformDataTemp;waveform ];
end 
else 
flag = 0;
end 
end 


end 
if ( flag == 0 )
if ( isempty( NodeWithissue ) )
NodeWithissue = { uniqueOutputs{ i } };
else 
NodeWithissue( end  + 1 ) = { uniqueOutputs{ i } };
end 
else 
flag = 0;
end 

end 

end 

nodesIssue = unique( NodeWithissue );
if ( ~isempty( nodesIssue ) )
disp( [ 'There were issues accessing waveforms for following nodes:', newline(  ) ] );
disp( nodesIssue' );
end 




warning( 'off', 'MATLAB:structOnObject' );
if ( ~isempty( waveformDataTemp ) )
waveformDataTemp = table2struct( waveformDataTemp );
fields = fieldnames( waveformDataTemp );

for i = 1:length( waveformDataTemp )
waveformDataStruct = struct( waveformDataTemp( i ).wave );
for j = 1:length( fields )
if ( ~strcmp( fields{ j }, 'wave' ) )
waveformDataStruct.( fields{ j } ) = waveformDataTemp( i ).( fields{ j } );
end 
end 
waveformData.no( i ) = waveformDataStruct;
end 
else 

waveformData = [  ];
end 

warning( 'on', 'MATLAB:structOnObject' );


if ( ~isempty( nodesIssue ) )
for i = 1:length( nodesIssue )
dbTables( ismember( dbTables.Output, nodesIssue{ i } ), : ) = [  ];
signalTables( ismember( signalTables.Output, nodesIssue{ i } ), : ) = [  ];
end 
end 

if initialSize > wResultsCornersOutputLastUsedIndex

for excess = initialSize: - 1:wResultsCornersOutputLastUsedIndex + 1
results.no( excess ) = [  ];
corners.no( excess ) = [  ];
output.no( excess ) = [  ];
end 
end 
if initialSize > sValueCornersScalarLastUsedIndex

for excess = initialSize: - 1:sValueCornersScalarLastUsedIndex + 1
sValue.no( excess ) = [  ];
sCorners.no( excess ) = [  ];
sScalar.no( excess ) = [  ];
end 
end 





maxDpoint = max( dbTables.DataPoint );
dPoint = 1;
k = 1;
for i = 1:maxDpoint
sizeTable = size( dbTables );
rowTable = sizeTable( 1 );
count = 1;

for i1 = 1:rowTable
if iscell_dbTablesResult
if ( strcmp( dbTables.Result{ i1 }, 'wave' ) )
if ( ( dbTables.DataPoint( i1 ) == dPoint ) )
count = count + 1;
wResultsCornersOutputLastUsedIndex = k;
results.no{ k } = dbTables.Result{ i1 };
if iscell_dbTablesCorner
corners.no{ k } = dbTables.Corner{ i1 };
else 
corners.no{ k } = dbTables.Corner( i1 );
end 
if iscell_dbTablesOutput
output.no{ k } = dbTables.Output{ i1 };
else 
output.no{ k } = dbTables.Output( i1 );
end 
k = k + 1;
end 
else 
if ( ( ( isa( dbTables.Result{ i1 }, 'logical' ) == 1 ) || ( dbTables.Result{ i1 } == false ) ) ...
 && ( dbTables.DataPoint( i1 ) == dPoint ) )
count = count + 1;
wResultsCornersOutputLastUsedIndex = k;
results.no{ k } = dbTables.Result{ i1 };
if iscell_dbTablesCorner
corners.no{ k } = dbTables.Corner{ i1 };
else 
corners.no{ k } = dbTables.Corner( i1 );
end 
if iscell_dbTablesOutput
output.no{ k } = dbTables.Output{ i1 };
else 
output.no{ k } = dbTables.Output( i1 );
end 
k = k + 1;
end 
end 

else 
if ( strcmp( dbTables.Result( i1 ), 'wave' ) )
if ( ( dbTables.DataPoint( i1 ) == dPoint ) )
count = count + 1;
wResultsCornersOutputLastUsedIndex = k;
results.no{ k } = dbTables.Result( i1 );
if iscell_dbTablesCorner
corners.no{ k } = dbTables.Corner{ i1 };
else 
corners.no{ k } = dbTables.Corner( i1 );
end 
if iscell_dbTablesOutput
output.no{ k } = dbTables.Output{ i1 };
else 
output.no{ k } = dbTables.Output( i1 );
end 
k = k + 1;
end 
else 
if ( ( ( dbTables.Result( i1 ) == 0 ) || ( dbTables.Result( i1 ) == false ) ) ...
 && ( dbTables.DataPoint( i1 ) == dPoint ) )
count = count + 1;
wResultsCornersOutputLastUsedIndex = k;
results.no{ k } = dbTables.Result( i1 );
if iscell_dbTablesCorner
corners.no{ k } = dbTables.Corner{ i1 };
else 
corners.no{ k } = dbTables.Corner( i1 );
end 
if iscell_dbTablesOutput
output.no{ k } = dbTables.Output{ i1 };
else 
output.no{ k } = dbTables.Output( i1 );
end 
k = k + 1;
end 
end 
end 

end 
dPoint = dPoint + 1;
end 
end 













if exist( 'results', 'var' )
wfResults = results.no;
else 
wfResults = [  ];
end 
if exist( 'corners', 'var' )
wfCorners = corners.no;
else 
wfCorners = [  ];
end 
if exist( 'output', 'var' )
wfOutput = output.no;
else 
wfOutput = [  ];
end 
if exist( 'waveformData', 'var' ) && ( ~isempty( waveformData ) )
waveformDB = waveformData.no;
else 
waveformDB = [  ];
end 

















save( fileName, 'dbTables', 'totalCorners', 'wfResults',  ...
'wfCorners', 'wfOutput', 'waveformDB',  ...
'simDBS', 'paramTable', 'paramConditionTable',  ...
'signalTables', 'exprTables', '-v7.3' );










disp( [ 'mat file (', fileName, ') created' ] );

if ( launchMSA )
h = matlabshared.application.IgnoreWarnings;
h.RethrowWarning = false;
mixedSignalAnalyzer( fileName );
end 
end 

function waveform = getWaveform( waveformType, netName )

import cadence.srrdata.*
import cadence.Query.*
import cadence.utils.*
import cadence.simdata.*
import cadence.srrsata.*
import cadence.streamCalculator.*
import cadence.utils.cdsPlot.*





try 
switch upper( waveformType )
case 'VT'
[ ~, waveform ] = evalc( 'VT(netName);' );
waveform.WaveType( : ) = { 'VT' };
waveform.Output( : ) = { netName };
case 'VS'

[ ~, waveform ] = evalc( 'VS(netName);' );
waveform.WaveType( : ) = { 'VS' };
waveform.Output( : ) = { netName };
case 'VDC'
waveform = [  ];



case 'VF'
[ ~, waveform ] = evalc( 'VF(netName);' );
waveform.WaveType( : ) = { 'VF' };
waveform.Output( : ) = { netName };
case 'IF'
[ ~, waveform ] = evalc( 'IF(netName);' );
waveform.WaveType( : ) = { 'IF' };
waveform.Output( : ) = { netName };
case 'IS'
[ ~, waveform ] = evalc( 'IS(netName);' );
waveform.WaveType( : ) = { 'IS' };
waveform.Output( : ) = { netName };
case 'IDC'
waveform = [  ];



case 'IT'
[ ~, waveform ] = evalc( 'IT(netName);' );
waveform.WaveType( : ) = { 'IT' };
waveform.Output( : ) = { netName };
case 'VN'
[ ~, waveform ] = evalc( 'VN(netName);' );
waveform.WaveType( : ) = { 'VN' };
waveform.Output( : ) = { netName };
case 'NG'
[ ~, waveform ] = evalc( 'NG(netName);' );
waveform.WaveType( : ) = { 'NG' };
waveform.Output( : ) = { netName };
otherwise 
waveform = [  ];
end 
catch 
waveform = [  ];

end 
end 

% Decoded using De-pcode utility v1.2 from file /tmp/tmp00gSi_.p.
% Please follow local copyright laws when handling this file.

