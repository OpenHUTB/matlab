function argOut = SLPerfLogData( action, varargin )


















































persistent mdlRefInfo;

if ~exist( 'mdlRefInfo', 'var' )
mdlRefInfo = [  ];
end 

argOut = [  ];

try 
switch action
case 'cacheMdlRefInfo'
if nargin < 4 || nargin > 4
DAStudio.error( 'Simulink:utility:invalidOption',  ...
'SLPerfLogData' );
end 
topMdl = varargin{ 1 };
mdlName = varargin{ 2 };
tgtName = varargin{ 3 };
if ~isfield( mdlRefInfo, topMdl )
mdlRefInfo.( topMdl ) = [  ];
end 
mdlRefInfo.( topMdl )( end  + 1 ).ModelName = mdlName;
mdlRefInfo.( topMdl )( end  ).ModelReferenceTargetType = tgtName;
case 'clearMdlRefInfo'
mdlRefInfo = [  ];
case 'get'
if nargin < 2
DAStudio.error( 'Simulink:utility:invalidOption',  ...
'SLPerfLogData' );
end 
mdlName = varargin{ 1 };
argOut = locGetCompStats( mdlName );
case 'getAll'
if nargin > 2
DAStudio.error( 'Simulink:utility:invalidOption',  ...
'SLPerfLogData' );
end 
argOut = SLPerfLogData( 'localGetAll', varargin{ : } );


numWorkers = loc_get_matlab_pool_size(  );
if ( numWorkers > 0 )
workerLogs = cell( 1, numWorkers );


parfor i = 1:numWorkers
workerLogs{ i } = SLPerfLogData( 'localGetAll',  ...
varargin{ : } );
end 


for i = 1:numWorkers
argOut = [ argOut, workerLogs{ i } ];%#ok - mlint
end 
end 
case 'localGetAll'
if nargin < 2


argOut = PerfTools.Tracer.getProcessedData(  ...
'grouping', 'All Simulink Compile' );
else 
mdlName = varargin{ 1 };
argOut = locGetCompStats( mdlName, mdlRefInfo );
end 
case 'clear'
argOut = true;
try 
if nargin > 2
DAStudio.error( 'Simulink:utility:invalidOption',  ...
'SLPerfLogData' );
end 
if nargin < 2
PerfTools.Tracer.clearRawData(  );


mdlRefInfo = [  ];
else 
mdlName = varargin{ 1 };
PerfTools.Tracer.clearRawData( 'model', mdlName );
end 
catch 
argOut = false;
end 
otherwise 
DAStudio.error( 'Simulink:utility:invalidOption',  ...
'SLPerfLogData' );
end 
catch %#ok<*CTCH>
DAStudio.error( 'Simulink:utility:invalidOption',  ...
'SLPerfLogData' );
end 

end 


function cStats = locGetCompStats( topMdl, varargin )
cStats = [  ];
mdls = { topMdl };
mdlRefInfo = [  ];
if nargin > 1
if ~isempty( varargin{ 1 } )


mdlRefInfo = varargin{ 1 }.( topMdl );
end 
if ~isempty( mdlRefInfo )
mdls = [ mdls, { mdlRefInfo.ModelName } ];
end 


normalRefMdls = loc_get_all_normal_modes( topMdl, {  }, {  } );
if ~isempty( normalRefMdls )
mdls = [ mdls, normalRefMdls' ];
end 


mdls = unique( mdls );
end 
nMdls = length( mdls );
for nn = 1:nMdls
mdlName = mdls{ nn };

mdlCStat = PerfTools.Tracer.getProcessedData( 'model', mdlName );
if isempty( mdlCStat )
continue ;
end 
cStats( nn ).Model = mdlName;
for mm = 1:length( mdlCStat )
cStats( nn ).Statistics( mm ).Description =  ...
mdlCStat{ mm }.phaseIDStr;
cStats( nn ).Statistics( mm ).IsParent =  ...
mdlCStat{ mm }.numChildren > 0;
cStats( nn ).Statistics( mm ).StatisticsType =  ...
mdlCStat{ mm }.statisticsTypeStr;
cStats( nn ).Statistics( mm ).Target =  ...
mdlCStat{ mm }.targetStr;
cStats( nn ).Statistics( mm ).CPUTime =  ...
mdlCStat{ mm }.cpuStartTime;
cStats( nn ).Statistics( mm ).CPUElapsedTime =  ...
mdlCStat{ mm }.cpuElapsedTime;
cStats( nn ).Statistics( mm ).WallClockTime =  ...
mdlCStat{ mm }.wcStartTime;
cStats( nn ).Statistics( mm ).WallClockElapsedTime =  ...
mdlCStat{ mm }.wcElapsedTime;
cStats( nn ).Statistics( mm ).ProcMemUsage =  ...
mdlCStat{ mm }.procMemUsage;
cStats( nn ).Statistics( mm ).ProcMemUsagePeak =  ...
mdlCStat{ mm }.procMemUsagePeak;
cStats( nn ).Statistics( mm ).ProcVMSize =  ...
mdlCStat{ mm }.procVMSize;
cStats( nn ).Statistics( mm ).ProcMemUsageDelta =  ...
mdlCStat{ mm }.procMemUsageDelta;
cStats( nn ).Statistics( mm ).ProcMemUsagePeakDelta =  ...
mdlCStat{ mm }.procMemUsagePeakDelta;
cStats( nn ).Statistics( mm ).ProcVMSizeDelta =  ...
mdlCStat{ mm }.procVMSizeDelta;
cStats( nn ).Statistics( mm ).FreeMem =  ...
mdlCStat{ mm }.freeMem;
cStats( nn ).Statistics( mm ).ReservedMem =  ...
mdlCStat{ mm }.resMem;
cStats( nn ).Statistics( mm ).CommittedMem =  ...
mdlCStat{ mm }.commitMem;
cStats( nn ).Statistics( mm ).DllsMem =  ...
mdlCStat{ mm }.dllsMem;
cStats( nn ).Statistics( mm ).NonProcessMem =  ...
mdlCStat{ mm }.nonprocessMem;
end 
clear mdlCStat;
end 
end 


function ioRefMdls = loc_get_all_normal_modes( iMdl,  ...
ioRefMdls,  ...
iPathToMdl )

mdlsToClose = slprivate( 'load_model', iMdl );
opts = { 'FollowLinks', 'on', 'LookUnderMasks', 'all' };


aBlks = find_system( iMdl, 'MatchFilter', @Simulink.match.internal.filterOutInactiveVariantSubsystemChoices, opts{ : }, 'BlockType', 'ModelReference' );

simModes = get_param( aBlks, 'SimulationMode' );
refMdls = get_param( aBlks, 'ModelName' );
slprivate( 'close_models', mdlsToClose );

pathToMdlRefsInMdl = [ iPathToMdl, { iMdl } ];
num = length( refMdls );
for idx = 1:num
refMdl = refMdls{ idx };
if ~isempty( strmatch( refMdl, pathToMdlRefsInMdl, 'exact' ) ), 
strPathToMdl = strcat_with_separator( pathToMdlRefsInMdl, ':' );
mdlRefLoop = [ strPathToMdl, ':', refMdl ];
MSLDiagnostic( 'Simulink:modelReference:detectedModelReferenceLoop',  ...
mdlRefLoop ).reportAsWarning;
continue ;
end 

matchIndex = strmatch( refMdl, ioRefMdls, 'exact' );
if isempty( matchIndex ) && strcmp( simModes{ idx }, 'Normal' )
ioRefMdls = loc_get_all_normal_modes( refMdl, ioRefMdls, pathToMdlRefsInMdl );
end 
end 
ioRefMdls = [ ioRefMdls;{ iMdl } ];
end 





function size = loc_get_matlab_pool_size(  )
size = 0;
try 
pool = gcp( 'nocreate' );
if ~isempty( pool ) && pool.Connected
size = pool.NumWorkers;
end 
catch 

end 
end 


% Decoded using De-pcode utility v1.2 from file /tmp/tmp_Fg2PH.p.
% Please follow local copyright laws when handling this file.

