function [ textout, report ] = sldiagnostics( sys, varargin )




















































































try 
if nargin == 1
[ textout, report ] = loc_sldiagnostics( sys, nargout );
else 
[ textout, report ] = loc_sldiagnostics( sys, nargout, varargin{ : } );
end 
catch myException
rethrow( myException );
end 
end 


function [ textout, report ] = loc_sldiagnostics( sys, outputsRequested, varargin )

if nargin == 2
doCountBlocks = true;
doCountSF = true;
doCompileStats = true;
doRTWBuildStats = false;
doReportSizes = true;
doCountLibs = true;
else 
doCountBlocks = false;
doCountSF = false;
doCompileStats = false;
doRTWBuildStats = false;
doReportSizes = false;
doCountLibs = false;
for k = 1:length( varargin )
option = varargin{ k };
if isstring( option )
option = convertStringsToChars( option );
end 

if ischar( option )
switch lower( option )
case 'countblocks'
doCountBlocks = true;
case 'countsf'
doCountSF = true;
case 'compilestats'
doCompileStats = true;
case 'rtwbuildstats'
doRTWBuildStats = true;
case 'verbose'
MSLDiagnostic( 'Simulink:utility:sldDiagnosticsVerboseStatsDeprecated' ).reportAsWarning
case 'sizes'
doReportSizes = true;
case 'libs'
doCountLibs = true;
case 'all'
doCountBlocks = true;
doCountSF = true;
doCompileStats = true;
doRTWBuildStats = true;
doReportSizes = true;
doCountLibs = true;
otherwise 
DAStudio.error( 'Simulink:utility:sldDiagnosticsUnknownOption' )
end 
else 
DAStudio.error( 'Simulink:utility:sldDiagnosticsUnknownOption' )
end 
end 
end 


if isstring( sys )
sys = convertStringsToChars( sys );
end 
[ mdl, sys, isSubSystem ] = checkopen( sys );





if bdIsLibrary( mdl )
if doCompileStats
MSLDiagnostic( 'Simulink:utility:sldDiagnosticsUnsupportedForLibraries',  ...
'CompileStats' ).reportAsWarning
doCompileStats = false;
end 
if doRTWBuildStats
MSLDiagnostic( 'Simulink:utility:sldDiagnosticsUnsupportedForLibraries',  ...
'RTWBuildStats' ).reportAsWarning
doRTWBuildStats = false;
end 
if doReportSizes
MSLDiagnostic( 'Simulink:utility:sldDiagnosticsUnsupportedForLibraries',  ...
'Sizes' ).reportAsWarning
doReportSizes = false;
end 
end 


if bdIsSubsystem( mdl )
if doCompileStats
MSLDiagnostic( 'Simulink:utility:sldDiagnosticsUnsupportedForSubsystemReference',  ...
'CompileStats' ).reportAsWarning
doCompileStats = false;
end 
if doReportSizes
MSLDiagnostic( 'Simulink:utility:sldDiagnosticsUnsupportedForSubsystemReference',  ...
'Sizes' ).reportAsWarning
doReportSizes = false;
end 
end 



if isSubSystem


if doCompileStats
MSLDiagnostic( 'Simulink:utility:sldDiagnosticsCompilesStatsGivenSys',  ...
'CompileStats' ).reportAsWarning
end 
if doRTWBuildStats
MSLDiagnostic( 'Simulink:utility:sldDiagnosticsCompilesStatsGivenSys',  ...
'RTWBuildStats' ).reportAsWarning
end 
if doReportSizes
MSLDiagnostic( 'Simulink:utility:sldDiagnosticsCompilesStatsGivenSys',  ...
'Sizes' ).reportAsWarning
end 
end 


textout = '';
blockrpt = [  ];
sfrpt = [  ];
sizerpt = [  ];
librpt = [  ];
compilerpt = [  ];
rtwrpt = [  ];

if ( ~doCountBlocks && ~doReportSizes && ~doCountLibs && ~doCountSF &&  ...
~doCompileStats && ~doRTWBuildStats ) && ( outputsRequested > 1 )
DAStudio.error( 'Simulink:utility:sldDiagnosticsStructureOutputNotValid' )
end 



if doCountBlocks



findBlocksOpts = Simulink.FindOptions(  ...
'FollowLinks', true,  ...
'IncludeCommented', false ...
 );
s = Simulink.findBlocks( sys, findBlocksOpts );






sfBlks = Simulink.findBlocks( sys, 'MaskType', 'Stateflow', findBlocksOpts );
theseDiscardables = Simulink.findBlocks( sfBlks, Simulink.FindOptions( 'SearchDepth', 1 ) );
s = setdiff( s, theseDiscardables );

total = numel( s );


rptStruct = struct( 'isMask', [  ], 'type', [  ], 'count', [  ] );
blockrpt = repmat( rptStruct, 1, 1 );

blockrpt( 1 ).isMask = 0;
blockrpt( 1 ).type = [ sys, ' Total blocks' ];
blockrpt( 1 ).count = 0;
maxNameWidth = length( blockrpt( 1 ).type );


sBlockTypes = cellstr( get_param( s, 'BlockType' ) );


for i = 1:length( sBlockTypes )
if strcmp( sBlockTypes{ i }, 'SubSystem' )
sfBlkType = get_param( s( i ), 'SFBlockType' );
if ~strcmp( sfBlkType, 'NONE' )
switch sfBlkType
case 'NONE'

case 'MATLAB Function'
sBlockTypes{ i } = 'MATLAB Function';
case 'Truth Table'
sBlockTypes{ i } = 'TruthTable';
otherwise 
sBlockTypes{ i } = 'Stateflow';
end 
end 
end 
end 
blockTypes = unique( sBlockTypes );

try 
sMaskTypes = cellstr( get_param( s, 'MaskType' ) );
maskTypes = unique( sMaskTypes );
if strcmp( maskTypes{ 1 }, '' )
maskTypes = maskTypes( 2:end  );
end 
numMaskTypes = numel( maskTypes );
catch E_ignored %#ok<NASGU>
numMaskTypes = 0;
end 

numRecs = length( blockTypes ) + numMaskTypes;
blockrpt = [ blockrpt;repmat( rptStruct, numRecs, 1 ) ];



for k = 1:length( blockTypes )
blockrpt( k + 1 ).isMask = 0;

blockrpt( k + 1 ).type = blockTypes{ k };
maxNameWidth = max( length( blockTypes{ k } ) + 1, maxNameWidth );

isOfBlockType = strcmp( sBlockTypes, blockTypes{ k } );
blockrpt( k + 1 ).count = sum( isOfBlockType );
end 

b = k + 1;

for k = 1:numMaskTypes
blockrpt( b + k ).isMask = 1;

blockrpt( b + k ).type = maskTypes{ k };
maxNameWidth = max( length( maskTypes{ k } ) + 1, maxNameWidth );

isOfMaskType = strcmp( sMaskTypes, maskTypes{ k } );
blockrpt( b + k ).count = sum( isOfMaskType );
end 





blockrpt( 1 ).count = total;


line1 = i_msg( 'sldDiagnosticsCountSummaryLine1', sys );
line2 = i_msg( 'sldDiagnosticsCountSummaryLine2', sprintf( '%d', total ) );
line3 = i_msg( 'sldDiagnosticsCountSummaryCountNote' );
line = sprintf( '%s\n%s\n\n%s\n', line1, line2, line3 );



textout = cell( numRecs + 1, 1 );
textout{ 1 } = sprintf( '%s\n', line );

fmtStr = [ '%1s %', sprintf( '%d', maxNameWidth + 2 ), 's : %5d\n' ];
NoteChars = ' M';
for k = 1:length( blockrpt )
if blockrpt( k ).count > 0
maskNote = NoteChars( 1 + blockrpt( k ).isMask );
textout{ k + 1 } = sprintf( fmtStr, maskNote,  ...
blockrpt( k ).type, blockrpt( k ).count );
end 
end 

textout = [ textout{ : } ];

end 


if doCountSF





find_system( sys, 'MatchFilter', @Simulink.match.internal.filterOutInactiveVariantSubsystemChoices, 'FollowLinks', 'on', 'LookUnderMasks', 'all' );


sfObjectTypeList = { 'Chart', 'GroupedState', 'State', 'Box',  ...
'EMFunction', 'EMChart', 'Function', 'LinkChart',  ...
'TruthTable', 'Note', 'Transition', 'Junction',  ...
'Event', 'Data', 'Target', 'Machine', 'SLFunction',  ...
'AtomicSubchart' };
numItems = length( sfObjectTypeList );
kg = strmatch( 'GroupedState', sfObjectTypeList, 'exact' );

rt = sfroot;
m = rt.find( '-isa', 'Stateflow.Machine', '-and', 'Name', mdl );
sfrpt = struct( 'class', [  ], 'count', [  ] );
sfrpt = repmat( sfrpt, numItems, 1 );
sfobjtxt = repmat( '', numItems, 1 );

groupedCount = 0;

for k = 1:numItems
if ishandle( m )

Hobjs = findDeep( m, sfObjectTypeList{ k } );
if isSubSystem


Hobjs_ind = true( size( Hobjs ) );
for kk = 1:numel( Hobjs )
Hobjs_ind( kk ) = i_compare_paths( Hobjs( kk ).Path, sys );
end 
Hobjs = Hobjs( Hobjs_ind );
end 

count = length( Hobjs );
else 
count = 0;
end 

if strcmp( sfObjectTypeList{ k }, 'State' )

for j = 1:count
if get( Hobjs( j ), 'IsGrouped' )
groupedCount = groupedCount + 1;
end 
end 
count = count - groupedCount;

sfrpt( kg ).class = sfObjectTypeList{ kg };
sfrpt( kg ).count = groupedCount;

sfobjtxt{ kg } = sprintf( '%25s : %4d', sfObjectTypeList{ kg }, groupedCount );
end 

sfrpt( k ).class = sfObjectTypeList{ k };
sfrpt( k ).count = count;

sfobjtxt{ k } = sprintf( '%25s : %4d', sfObjectTypeList{ k }, count );

end 


ind_chart = strmatch( 'Chart', sfObjectTypeList, 'exact' );%#ok<*MATCH3>
ind_asubchart = strmatch( 'AtomicSubchart', sfObjectTypeList, 'exact' );
sfrpt( ind_chart ).count = sfrpt( ind_chart ).count -  ...
sfrpt( ind_asubchart ).count;

sftextout = sprintf( '\n%s',  ...
i_position_string( i_msg( 'sldiagnosticsStateflowCount' ) ) );
sftextout = sprintf( '%s\n%s\n', sftextout, sfobjtxt{ : } );
sftextout = sprintf( '%s%s\n', sftextout,  ...
i_position_string( i_msg( 'sldiagnosticsEndStateflowCount' ) ) );

textout = [ textout, sftextout ];
end 


if doReportSizes



try 
[ ~, stats ] = evalc( [ get_param( mdl, 'Name' ), '([],[],[],0)' ] );
catch E
MSLDiagnostic(  ...
'Simulink:utility:sldiagnosticsFailedToGetSizes', E.message ).reportAsWarning
stats = zeros( 7, 1 );
end 

sizesMsgCell = {  ...
i_msg( 'sldiagnosticsNumberContinuousStates' ),  ...
i_msg( 'sldiagnosticsNumberDiscreteStates' ),  ...
i_msg( 'sldiagnosticsNumberOutputs' ),  ...
i_msg( 'sldiagnosticsNumberInputs' ),  ...
i_msg( 'sldiagnosticsFlagFeedThrough' ),  ...
i_msg( 'sldiagnosticsNumberSampleTimes' ) ...
 };

sizesMsgCell = i_right_justify( sizesMsgCell );

textout = sprintf( '%s\n\n%s', textout,  ...
i_position_string( i_msg( 'sldiagnosticsModelSizes' ) ) );

NumContStates = stats( 1 );
NumDiscStates = stats( 2 );
NumOutputs = stats( 3 );
NumInputs = stats( 4 );
DirFeedthrough = stats( 6 );
NumSampleTimes = stats( 7 );

textout = sprintf( '%s\n%s\t\t%d', textout, sizesMsgCell{ 1 }, NumContStates );
textout = sprintf( '%s\n%s\t\t%d', textout, sizesMsgCell{ 2 }, NumDiscStates );
textout = sprintf( '%s\n%s\t\t%d', textout, sizesMsgCell{ 3 }, NumOutputs );
textout = sprintf( '%s\n%s\t\t%d', textout, sizesMsgCell{ 4 }, NumInputs );
textout = sprintf( '%s\n%s\t\t%d', textout, sizesMsgCell{ 5 }, DirFeedthrough );
textout = sprintf( '%s\n%s\t\t%d', textout, sizesMsgCell{ 6 }, NumSampleTimes );

textout = sprintf( '%s\n%s\n', textout,  ...
i_position_string( i_msg( 'sldiagnosticsModelSizesEnd' ) ) );

sizerpt = struct( 'NumContStates', NumContStates,  ...
'NumDiscStates', NumDiscStates,  ...
'NumOutputs', NumOutputs,  ...
'NumInputs', NumInputs,  ...
'DirFeedthrough', DirFeedthrough,  ...
'NumSampleTimes', NumSampleTimes );
end 


if doCountLibs

textout = sprintf( '%s\n%s', textout,  ...
i_position_string( i_msg( 'sldiagnosticsLibraryUsageStatistics' ) ) );


library_blocks = libinfo( sys, 'MatchFilter', @Simulink.match.internal.filterOutInactiveVariantSubsystemChoices );

if isempty( library_blocks )
textout = sprintf( '%s\n%s%s', textout,  ...
i_msg( 'sldiagnosticsNoLibraryUsed', sys ) );
else 
libListLen = length( library_blocks );
[ libList{ 1:libListLen } ] = deal( library_blocks.Library );
[ refList{ 1:libListLen } ] = deal( library_blocks.ReferenceBlock );

[ uLibList, noDups ] = findUniqueObjs( libList );
textout = sprintf( '%s\n%s\n', textout, i_msg( 'sldiagnosticsListUniqueLibs' ) );
for i = 1:length( uLibList )
textout = sprintf( '%s   %s\n', textout, uLibList{ i } );
end 

textout = sprintf( '%s\n\n%s', textout,  ...
i_msg( 'sldiagnosticsLibBlocksAndCounts' ) );

librpt = repmat( struct( 'libName', [  ], 'numLinksToLib', [  ] ),  ...
1, length( uLibList ) );
for i = 1:length( uLibList )
textout = sprintf( '%s\n\n  %s %s', textout,  ...
i_msg( 'sldiagnosticsLibrary' ), uLibList{ i } );
textout = sprintf( '%s [%s %d]', textout,  ...
i_msg( 'sldiagnosticsNumLinksToLib' ), noDups( i ) );
librpt( i ).libName = uLibList( i );
librpt( i ).numLinksToLib = noDups( i );


refBlkList = refList( ismember( libList, uLibList( i ) ) );


[ uRefBlkList, noRefDups ] = findUniqueObjs( refBlkList );

for j = 1:length( uRefBlkList )
tmp4 = regexprep( uRefBlkList{ j }, '\n', ' ' );
if noRefDups( j ) == 1
instStr = i_msg( 'sldiagnosticsInstance', noRefDups( j ) );
else 
instStr = i_msg( 'sldiagnosticsInstances', noRefDups( j ) );
end 

textout = sprintf( '%s\n    %s %s\n           [%s]',  ...
textout, i_msg( 'sldiagnosticsBlock' ), tmp4, instStr );
librpt( i ).refBlocks( j ).blockName = tmp4;
librpt( i ).refBlocks( j ).numInstances = noRefDups( j );
end 
end 
end 
textout = sprintf( '%s\n\n%s\n', textout,  ...
i_position_string( i_msg( 'sldiagnosticsLibraryUsageStatisticsEnd' ) ) );
end 


if doCompileStats




try 

PerfTools.Tracer.clearRawData(  );
scsOriginal = PerfTools.Tracer.enable( 'All Simulink Compile' );
PerfTools.Tracer.enable( 'All Simulink Compile', true );
cleanupObj1 = onCleanup( @(  )loc_PerfTracerCleanupAction(  ...
scsOriginal ) );
statsTxt = [  ...
evalc( 'feval(mdl,[],[],[],''compile'');' ),  ...
evalc( 'feval(mdl,[],[],[],''term'');' ) ];%#ok<NASGU>
catch actualLastError

try 

PerfTools.Tracer.clearRawData(  );
statsTxt = [  ...
evalc( 'feval(mdl,[],[],[],''compileForSizes'');' ),  ...
evalc( 'feval(mdl,[],[],[],''term'');' ) ];%#ok<NASGU>



MSLDiagnostic(  ...
'Simulink:utility:sldDiagnosticsRanReducedCompileStats',  ...
actualLastError.message ).reportAsWarning
catch E_ignore


if ~strcmp( get_param( mdl, 'SimulationStatus' ), 'stopped' )
try 
evalc( 'feval(mdl,[],[],[],''term'');' );
catch E_ignored %#ok<NASGU>

end 
end 
newExc = MException( 'Simulink:utility:ErrorFoundDuringCompileStats',  ...
i_msg( 'sldDiagnosticsCompileStatsFailed' ) );
newExc = newExc.addCause( actualLastError );
throw( newExc );
end 
end 


cstatData = slprivate( 'SLPerfLogData', 'get', mdl );


[ statsFormatted, compilerpt ] = loc_formatCStatsOutput( cstatData );


PerfTools.Tracer.enable( 'All Simulink Compile', scsOriginal );


if isempty( textout )
textout = statsFormatted;
else 
textout = sprintf( '%s\n%s\n%s', textout,  ...
i_position_string( i_msg( 'sldiagnosticsCompilationStats' ) ),  ...
statsFormatted );
end 
end 

if doRTWBuildStats
try 
if license( 'test', 'Real-Time_Workshop' )
PerfTools.Tracer.clearRawData(  );

scsOriginal = PerfTools.Tracer.enable(  ...
'All Simulink Compile' );

PerfTools.Tracer.enable( 'All Simulink Compile', true );
cleanupObj2 = onCleanup( @(  )loc_PerfTracerCleanupAction(  ...
scsOriginal ) );
evalc( 'slbuild(mdl)' );
cstatData = slprivate( 'SLPerfLogData', 'get', mdl );

[ statsFormatted, rtwrpt ] = loc_formatCStatsOutput( cstatData );


if isempty( textout )
textout = statsFormatted;
else 
textout = sprintf( '%s\n%s\n%s', textout,  ...
i_position_string( i_msg( 'sldiagnosticsCompilationStats' ) ),  ...
statsFormatted );
end 

else 
rtwrpt = '';
end 
catch actualLastError
newExc = MException( 'Simulink:utility:ErrorFoundDuringRTWBuildStats',  ...
i_msg( 'sldDiagnosticsRTWBuildStatsFailed' ) );
newExc = newExc.addCause( actualLastError );
throw( newExc );
end 
end 




if ( ~isempty( blockrpt ) + ~isempty( sfrpt ) +  ...
~isempty( sizerpt ) + ~isempty( librpt ) +  ...
~isempty( compilerpt ) + ~isempty( rtwrpt ) ) >= 2


report = struct(  ...
'blocks', [  ],  ...
'sizes', [  ],  ...
'links', [  ],  ...
'stateflow', [  ],  ...
'compilestats', [  ],  ...
'rtwbuild', [  ] ...
 );
if ~isempty( blockrpt )
report.blocks = blockrpt;
end 
if ~isempty( sizerpt )
report.sizes = sizerpt;
end 
if ~isempty( librpt )
report.links = librpt;
end 
if ~isempty( sfrpt )
report.stateflow = sfrpt;
end 
if ~isempty( compilerpt )
report.compilestats = compilerpt;
end 
if ~isempty( rtwrpt )
report.rtwbuild = rtwrpt;
end 
else 


if ~isempty( librpt )
report = librpt;
elseif ~isempty( sfrpt )
textout = sftextout;
report = sfrpt;
elseif ~isempty( sizerpt )
report = sizerpt;
elseif ~isempty( compilerpt )
report = compilerpt;
elseif ~isempty( rtwrpt )
report = rtwrpt;
else 
report = blockrpt;
end 
end 

end 


function b = i_compare_paths( p, sys )

p = strrep( p, newline, ' ' );
sys = strrep( sys, newline, ' ' );
b = strncmp( p, sys, numel( sys ) );
end 



function [ mdl, sys, isSubSystem ] = checkopen( sys )



if isempty( sys )
DAStudio.error( 'Simulink:utility:sldDiagnosticsNoModelSpecified' )
end 




if strcmp( sys( end  ), '/' )
sys = sys( 1:end  - 1 );
end 
[ mdl, rest ] = strtok( sys, '/' );

isSubSystem = ~isempty( rest );


load_system( mdl );



if isSubSystem
sys = getfullname( sys );
end 

end 


function [ uList, nDups ] = findUniqueObjs( iList )



tmpList = sort( iList );
[ uList, I ] = unique( tmpList );


nDups = diff( [ I;length( iList ) + 1 ] )';
end 


function str = i_position_string( str_in )

targetLen = 48;
dashLen = floor( ( targetLen - length( str_in ) ) / 2 );
dashes = repmat( '-', 1, dashLen );
str = [ dashes, ' ', str_in, ' ', dashes ];
if length( str ) / 2 ~= floor( length( str ) / 2 )

str = [ '-', str ];
end 
end 

function strOut = i_right_justify( strIn )

strOut = strIn;
L = max( cellfun( @length, strOut ) );
for jj = 1:numel( strOut )
strOut{ jj } = [ repmat( ' ', 1, L - length( strOut{ jj } ) ), strOut{ jj }, ':' ];
end 
end 

function str = i_msg( key, varargin )


key = [ 'Simulink:utility:', key ];
str = DAStudio.message( key, varargin{ : } );
end 

function [ statsFormatted, rptData ] = loc_formatCStatsOutput( cstats )

rptData.Model = cstats.Model;
numStats = length( cstats.Statistics );
mdlName = cstats.Model;
statsFormatted = sprintf( '--- Compile Statistics For: %s\n', mdlName );
idx = 1;
for ss = 1:numStats
if ~cstats.Statistics( ss ).IsParent
if idx < 10
tabs = sprintf( '\t\t' );
else 
tabs = sprintf( '\t' );
end 
rptData.Statistics( idx ).Description = cstats.Statistics( ss ).Description;
rptData.Statistics( idx ).CPUTime = cstats.Statistics( ss ).CPUElapsedTime;
rptData.Statistics( idx ).WallClockTime = cstats.Statistics( ss ).WallClockElapsedTime;
rptData.Statistics( idx ).ProcessMemUsage = cstats.Statistics( ss ).ProcMemUsageDelta;
rptData.Statistics( idx ).ProcessMemUsagePeak = cstats.Statistics( ss ).ProcMemUsagePeakDelta;
rptData.Statistics( idx ).ProcessVMSize = cstats.Statistics( ss ).ProcVMSizeDelta;
statsFormatted = [ statsFormatted ...
, sprintf( '\tCstat%d:%s%8.2f seconds -- %s\n', idx, tabs,  ...
cstats.Statistics( ss ).WallClockElapsedTime,  ...
cstats.Statistics( ss ).Description ) ];%#ok<AGROW>
idx = idx + 1;
end 
end 
end 

function loc_PerfTracerCleanupAction( scsOriginal )
PerfTools.Tracer.enable( 'All Simulink Compile', scsOriginal );
PerfTools.Tracer.clearRawData(  );
end 


% Decoded using De-pcode utility v1.2 from file /tmp/tmp8vikMc.p.
% Please follow local copyright laws when handling this file.

