function [ buildTime, optNumWorkers, nodeTime, scheduleOrder, finishedOrder ] =  ...
estimateParBuildTime( topModel, overheadFactor, quickEstimate, varargin )









































if isempty( varargin )

isSimulation = true;
else 
isSimulation = varargin{ 1 };
end 

if nargin > 4
binSearch = varargin{ 2 };
else 
binSearch = false;
end 

if nargin > 5
oStruct = varargin{ 3 };
parMdlRefs = varargin{ 4 };
slBuildIsInUse = true;
else 
oStruct = [  ];
parMdlRefs = [  ];
slBuildIsInUse = false;
end 

buildTime = 0;%#ok<NASGU>
optNumWorkers = 0;%#ok<NASGU>
scheduleOrder = {  };%#ok<NASGU>
finishedOrder = {  };%#ok<NASGU>


if isSimulation





targetType = 'SIM';
else 

targetType = 'RTW';
end 





lIsRapidAccelerator = false;
if strcmp( targetType, 'SIM' )
topMdlSimMode = get_param( topModel, 'SimulationMode' );
if strcmp( topMdlSimMode, 'normal' )


includeTopMdl = false;
else 




includeTopMdl = true;













lIsRapidAccelerator = true;
end 
else 

includeTopMdl = true;
end 

if isempty( oStruct )


cleanupGenSettingsCache = coder.internal.infoMATInitializeFromSTF ...
( get_param( topModel, 'SystemTargetFile' ), topModel );%#ok

[ oStruct, parMdlRefs ] = get_ordered_model_references ...
( topModel,  ...
true,  ...
'ModelReferenceTargetType', targetType,  ...
'TopOfBuildModel', topModel,  ...
'IsRapidAccelerator', lIsRapidAccelerator );


clear cleanupGenSettingsCache

if ~includeTopMdl

oStruct = oStruct( 1:end  - 1 );
parMdlRefs = parMdlRefs( 1:end  - 1 );
end 
else 


includeTopMdl = strcmp( topModel, oStruct( end  ).modelName );
end 

[ oStruct, parMdlRefs, isInSecond, hasEstimation ] =  ...
parComputeWeights( oStruct, parMdlRefs, targetType, slBuildIsInUse );
[ targetBuildTime, targetOptNumWorkers, targetScheduleOrder, targetFinishedOrder, targetMdlStruct ] =  ...
locComputeOverallParBuildTime( oStruct, parMdlRefs, isInSecond, hasEstimation, targetType,  ...
overheadFactor, quickEstimate, includeTopMdl, binSearch,  ...
slBuildIsInUse );

targetNodeName = { targetMdlStruct.modelName };
targetNodeTime = [ targetMdlStruct.buildTime ];






buildTime = targetBuildTime;
optNumWorkers = targetOptNumWorkers;
scheduleOrder = targetScheduleOrder;
finishedOrder = targetFinishedOrder;
nodeTime = struct( 'targetNodeName', { targetNodeName }, 'targetNodeTime', targetNodeTime );
end 






function [ totBTime, optNumWorkers, scheduleOrder, finishedOrder, oStruct, parMdlRefs ] =  ...
locComputeOverallParBuildTime( oStruct, parMdlRefs, isInSecond, hasEstimation,  ...
targetType, overheadFactor, quickEstimate, includeTopMdl, binSearch,  ...
slBuildIsInUse )

if ~( ~includeTopMdl && isempty( oStruct ) )




if quickEstimate
if ~isInSecond
[ oStruct, parMdlRefs ] =  ...
locConvertBuildTime( 'convertToSecondForQuickEstimate', oStruct, parMdlRefs, targetType,  ...
slBuildIsInUse );
end 
else 
if hasEstimation
[ oStruct, parMdlRefs ] =  ...
locConvertBuildTime( 'convertUsingFullBuilds', oStruct, parMdlRefs, targetType, slBuildIsInUse );
end 
end 







[ oStruct, parMdlRefs ] = locCheckBuildTime( oStruct, parMdlRefs );
end 

if includeTopMdl
maxNumWorkers = length( oStruct ) - 1;
else 
maxNumWorkers = length( oStruct );
end 

if isempty( parMdlRefs )
ReadyListInitial = {  };
else 
[ ~, sIdx ] = sort( [ parMdlRefs{ 1 }( : ).weight ], 'descend' );
ReadyListInitial = parMdlRefs{ 1 }( sIdx );
end 

if binSearch

[ totBTime, scheduleOrder, finishedOrder ] = locBinaryCalc( oStruct, maxNumWorkers, ReadyListInitial );
else 

[ totBTime, scheduleOrder, finishedOrder ] = locLinearCalc( oStruct, maxNumWorkers, ReadyListInitial );
end 



if includeTopMdl
N = length( parMdlRefs ) - 1;
totBTime( 1 ) = sum( [ oStruct( 1:end  - 1 ).buildTime ] );
else 
N = length( parMdlRefs );
totBTime( 1 ) = sum( [ oStruct.buildTime ] );
end 


idx = ( totBTime > 0 );

scheduledList = {  };
for n = 1:N
scheduledList( end  + 1:end  + length( parMdlRefs{ n } ) ) = { parMdlRefs{ n }.modelName };
end 
scheduleOrder{ 1 } = scheduledList;

finishedOrder{ 1 } = scheduleOrder{ 1 };


if includeTopMdl

totBTime( idx ) = totBTime( idx ) + oStruct( end  ).buildTime;

for n = 1:max( maxNumWorkers, 1 )
if totBTime( n ) == 0
continue ;
end 
scheduleOrder{ n } = [ scheduleOrder{ n }, oStruct( end  ).modelName ];
finishedOrder{ n } = [ finishedOrder{ n }, oStruct( end  ).modelName ];
end 
end 

optNumWorkers = find( totBTime == min( totBTime( idx ) ), 1 );
if isempty( optNumWorkers ) || ( optNumWorkers == 0 )
optNumWorkers = 1;
end 




totBTime( 2:end  ) = ( 1 + overheadFactor ) * totBTime( 2:end  );

end 


function [ totBTime, scheduleOrder, finishedOrder ] = locLinearCalc( oStruct, numMdlRefs, ReadyListInitial )
totBTime = zeros( 1, numMdlRefs );
scheduleOrder = cell( numMdlRefs, 1 );
finishedOrder = cell( numMdlRefs, 1 );
for numWorkers = 2:numMdlRefs
[ bTime, scheduledList, tmpFinishedOrder ] = calcBuildTime( oStruct, numWorkers, numMdlRefs, ReadyListInitial );
totBTime( numWorkers ) = bTime;
scheduleOrder{ numWorkers } = scheduledList;
finishedOrder{ numWorkers } = tmpFinishedOrder;
end 
end 


function [ totBTime, scheduleOrder, finishedOrder ] = locBinaryCalc( oStruct, numMdlRefs, ReadyListInitial )
totBTime = zeros( 1, numMdlRefs );
scheduleOrder = cell( numMdlRefs, 1 );
finishedOrder = cell( numMdlRefs, 1 );

hiIdx = numMdlRefs;
loIdx = 2;
curNumWorkers = numMdlRefs;




if ( curNumWorkers == 0 )
optimalWorkersFound = true;
else 
optimalWorkersFound = false;
end 



minBTime = pow2( 31 );

while ~optimalWorkersFound
[ bTime, scheduledList, tmpFinishedOrder ] = calcBuildTime( oStruct, curNumWorkers, numMdlRefs, ReadyListInitial );
totBTime( curNumWorkers ) = bTime;
scheduleOrder{ curNumWorkers } = scheduledList;
finishedOrder{ curNumWorkers } = tmpFinishedOrder;

if bTime > minBTime

loIdx = curNumWorkers;
else 


hiIdx = curNumWorkers;
minBTime = bTime;
end 
curNumWorkers = loIdx + floor( ( hiIdx - loIdx ) / 2 );

if totBTime( curNumWorkers ) > 0

optimalWorkersFound = true;
end 
end 
end 


function [ bTime, scheduledList, finishedOrder ] = calcBuildTime( locOStruct, numWorkers, totNumMdlRef, ReadyListInitial )
bTime = 0;
finishedNodes = cell( 1, 0 );



cTask = cell( 1, numWorkers );
cTaskTime = zeros( 1, numWorkers );
buffer = cell( 1, 1 );
scheduledList = {  };


readyToBuild = ReadyListInitial;


N = min( length( readyToBuild ), numWorkers + 1 );
for n = 1:N - 1
cTask{ n } = readyToBuild( n );
cTaskTime( n ) = cTask{ n }.buildTime;
end 
if N > numWorkers
buffer{ : } = readyToBuild( N );
else 
cTask{ N } = readyToBuild( N );
cTaskTime( N ) = cTask{ N }.buildTime;
end 

scheduledList( end  + 1:end  + N ) = { readyToBuild( 1:N ).modelName };
readyToBuild = readyToBuild( N + 1:end  );

while length( finishedNodes ) < totNumMdlRef
deltaTime = min( cTaskTime( cTaskTime ~= 0 ) );
idx = ( cTaskTime == deltaTime );
finishedNodes( end  + 1:end  + sum( idx ) ) = cTask( idx );
cTaskTime = cTaskTime - deltaTime;
cTaskTime( cTaskTime < 0 ) = 0;
bTime = bTime + deltaTime;

[ locOStruct, readyToBuild ] = locUpdateReadyList( locOStruct, readyToBuild, cTask( idx ) );

if ~isempty( buffer{ : } )
tmpIdx = find( cTaskTime == 0, 1 );
cTask{ tmpIdx } = buffer{ : };
cTaskTime( tmpIdx ) = cTask{ tmpIdx }.buildTime;
buffer{ : } = [  ];
end 




if ( ( length( finishedNodes ) + sum( cTaskTime ~= 0 ) ) < totNumMdlRef ) && ~isempty( readyToBuild )


[ cTaskTime, sIdx ] = sort( cTaskTime );
cTask = cTask( sIdx );


numFreeWorkers = sum( cTaskTime == 0 );
N = min( length( readyToBuild ), numFreeWorkers + 1 );
for n = 1:N - 1
cTask{ n } = readyToBuild( n );
cTaskTime( n ) = cTask{ n }.buildTime;
end 
if N > numFreeWorkers
buffer{ : } = readyToBuild( N );
else 
cTask{ N } = readyToBuild( N );
cTaskTime( N ) = cTask{ N }.buildTime;
end 

scheduledList( end  + 1:end  + N ) = { readyToBuild( 1:N ).modelName };
readyToBuild = readyToBuild( N + 1:end  );
end 
end 
tmpStruct = [ finishedNodes{ : } ];
finishedOrder = { tmpStruct.modelName };
end 




function [ oStruct, parMdlRefs ] = locConvertBuildTime( action, oStruct, parMdlRefs, targetType, slBuildIsInUse )

if strcmp( targetType, 'SIM' )
mdlreftarget = 'ModelReferenceSimTarget';
else 
mdlreftarget = 'ModelReferenceCoderTargetOnly';
end 

switch action
case 'convertToSecondForQuickEstimate'




s = sort( [ parMdlRefs{ 1 }( : ).buildTime ] );
idx = find( s >= mean( s ), 1 );
mIdx = find( [ parMdlRefs{ 1 }( : ).buildTime ] == s( idx ), 1 );
mMdl = parMdlRefs{ 1 }( mIdx ).modelName;


cfs = paprivate( 'utilGetActiveConfigSet', mMdl );
configSet = cfs.configSet;
oldSettings = configSet.get_param( 'UpdateModelReferenceTargets' );

if strcmp( oldSettings, 'AssumeUpToDate' )
slbuild( mMdl, mdlreftarget, 'UpdateThisModelReferenceTarget', 'Force' );
else 
slbuild( mMdl, mdlreftarget );
end 


mdlsToClose = slprivate( 'load_model', mMdl );
mdlsToCloseCleanupFcn = onCleanup( @(  )slprivate( 'close_models', mdlsToClose ) );
lSystemTargetFile = get_param( mMdl, 'SystemTargetFile' );
clear mdlsToCloseCleanupFcn

try 
bs = coder.internal.infoMATPostBuild ...
( 'getBuildStats', 'binfo', mMdl, targetType, lSystemTargetFile );
catch ME
throw( ME );
end 

testBuildTime = bs.buildTime;
testFileSize = parMdlRefs{ 1 }( mIdx ).buildTime;
fileSizeToTimeFactor = testBuildTime / testFileSize;

mdlBTimes = [ oStruct( : ).buildTime ] * fileSizeToTimeFactor;
mdlBTimes = num2cell( mdlBTimes );
[ oStruct( : ).buildTime ] = deal( mdlBTimes{ : } );

case 'convertUsingFullBuilds'

numMdlToBuild = length( oStruct );
for i = 1:numMdlToBuild
iMdl = oStruct( i ).modelName;


mdlsToClose = slprivate( 'load_model', iMdl );
mdlsToCloseCleanupFcn = onCleanup( @(  )slprivate( 'close_models', mdlsToClose ) );
lSystemTargetFile = get_param( iMdl, 'SystemTargetFile' );
clear mdlsToCloseCleanupFcn

try 
bs = coder.internal.infoMATPostBuild ...
( 'getBuildStats', 'binfo', iMdl, targetType, lSystemTargetFile );
oStruct( i ).buildTime = bs.buildTime;
catch 
if slBuildIsInUse






oStruct( i ).buildTime = realmin;
else 

cfs = paprivate( 'utilGetActiveConfigSet', iMdl );
configSet = cfs.configSet;
oldSettings = configSet.get_param( 'UpdateModelReferenceTargets' );

if strcmp( oldSettings, 'AssumeUpToDate' )
slbuild( iMdl, mdlreftarget, 'UpdateThisModelReferenceTarget', 'Force' );
else 
slbuild( iMdl, mdlreftarget );
end 

bs = coder.internal.infoMATPostBuild ...
( 'getBuildStats', 'binfo', iMdl, targetType, lSystemTargetFile );
oStruct( i ).buildTime = bs.buildTime;
end 
end 
end 
end 


allNodeNames = { oStruct( : ).modelName };
for lvl = 1:length( parMdlRefs )
[ ~, idx ] = ismember( { parMdlRefs{ lvl }( : ).modelName }, allNodeNames );
[ parMdlRefs{ lvl }( : ).buildTime ] = oStruct( idx ).buildTime;
end 
end 


function [ oStruct, parMdlRefs ] = locCheckBuildTime( oStruct, parMdlRefs )

if isempty( oStruct )
return ;
end 


oStructIdx = ( [ oStruct.buildTime ] == 0 );
[ oStruct( oStructIdx ).buildTime ] = deal( realmin );


bt0Names = { oStruct( oStructIdx ).modelName };
for lvl = 1:length( parMdlRefs )
idx = ismember( { parMdlRefs{ lvl }( : ).modelName }, bt0Names );
[ parMdlRefs{ lvl }( idx ).buildTime ] = deal( realmin );
end 
end 


function [ oStruct, readyToBuild ] = locUpdateReadyList( oStruct, readyToBuild, justFinished )

parentNodeList = cell( 1, 0 );
for n = 1:length( justFinished )
node = justFinished{ n };

[ ~, idx ] = ismember( node.modelName, { oStruct( : ).modelName } );
oStruct( idx ) = [  ];

[ tf, idx ] = ismember( node.directParents, { oStruct( : ).modelName } );
if any( tf )
parentNodeList( end  + 1:end  + length( idx( tf ) ) ) = num2cell( oStruct( idx( tf ) ) );
end 
end 

if ~isempty( parentNodeList )

tmpStruct = [ parentNodeList{ : } ];
parentNameList = { tmpStruct.modelName };
[ ~, ia ] = unique( parentNameList, 'stable' );
parentNodeList = parentNodeList( ia );
end 

for numPNode = 1:length( parentNodeList )
tf = ismember( parentNodeList{ numPNode }.children, { oStruct( : ).modelName } );
if ~any( tf )


readyToBuild( end  + 1 ) = parentNodeList{ numPNode };%#ok<AGROW>
[ ~, sIdx ] = sort( [ readyToBuild( : ).weight ], 'descend' );
readyToBuild = readyToBuild( sIdx );
end 
end 

end 

% Decoded using De-pcode utility v1.2 from file /tmp/tmpgGsUPL.p.
% Please follow local copyright laws when handling this file.

