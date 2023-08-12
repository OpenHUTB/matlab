function hardwareResults = parseToolReports( obj, varargin )








workflowSteps = varargin;
if iscellstr( workflowSteps )%#ok<ISCLSTR>
workflowSteps = { workflowSteps };
end 


edaTool = obj.get( 'Tool' );

projectName = obj.hToolDriver.hTool.ProjectName;

projectDir = obj.hToolDriver.hTool.ProjectDir;


if strcmpi( edaTool, 'Xilinx Vivado' )
hardwareResults = parseVivadoReports( obj, projectName, projectDir, workflowSteps );
elseif strcmpi( edaTool, 'Altera QUARTUS II' )
hardwareResults = parseQuartusReports( obj, projectName, projectDir, workflowSteps );
elseif strcmpi( edaTool, 'Intel Quartus Pro' )
hardwareResults = parseQuartusProReports( obj, projectName, projectDir, workflowSteps );
else 
hardwareResults = [  ];
end 
end 

function hardwareResults = parseVivadoReports( hDI, projectName, projectDir, workflowSteps )


hardwareResults = [  ];
try 



dutName = projectName( 1:end  - 7 );

parserObj = HDLReadStatistics( dutName, 'TargetDir', projectDir, 'SynthTool', 'Xilinx Vivado' );



if strcmpi( workflowSteps{ 1 }{ 1 }, 'Synthesis' )

[ parsedResults, metadata ] = parserObj.readResults( workflowSteps{ 1 }{ 1 }, false, 'ReadTiming', ~hDI.SkipPreRouteTimingAnalysis );
elseif strcmpi( workflowSteps{ 1 }{ 1 }, 'Implementation' )
[ parsedResults, metadata ] = parserObj.readResults( workflowSteps{ 1 }{ 1 }, false, 'ReadTiming', true );
else 
return ;
end 




resourceVariables = { metadata.lutsStr;metadata.sliceRegsStr; ...
metadata.DSPsStr;metadata.RAMsStr;metadata.URAMsStr };

usage = [ parsedResults.LUTs, parsedResults.SliceRegs,  ...
parsedResults.DSPs, parsedResults.RAMs, parsedResults.URAMs ];

availableResources = [ parsedResults.MaxLUTs, parsedResults.MaxSliceRegs,  ...
parsedResults.MaxDSPs, parsedResults.MaxRAMs, parsedResults.MaxURAMs ];

utilization = ( usage ./ availableResources ) .* 100;

hardwareResults.ResourceVariables = resourceVariables;
hardwareResults.ResourceData = formatData( usage, '%d' );
hardwareResults.AvailableResources = formatData( availableResources, '%d' );
hardwareResults.Utilization = formatData( utilization, '%.2f' );
hardwareResults.ResourceFile = metadata.UtilReportFileName;




isQuartus = false;
[ timingVariables, timingData ] = getTimingData( hDI, metadata, parsedResults, isQuartus );

hardwareResults.TimingVariables = timingVariables;
hardwareResults.TimingData = timingData;
hardwareResults.TimingFile = metadata.RPTFileName;
hardwareResults.Slack = parsedResults.Slack;
catch 
hardwareResults = [  ];
end 
end 

function hardwareResults = parseQuartusReports( hDI, projectName, projectDir, workflowSteps )


hardwareResults = [  ];
try 



dutName = projectName( 1:end  - 8 );

parserObj = HDLReadStatistics( dutName, 'TargetDir', projectDir, 'SynthTool', 'Altera QUARTUS II' );






if strcmpi( workflowSteps{ 1 }{ 1 }, 'Map' )

[ parsedResults, metadata ] = parserObj.readResults( workflowSteps{ 1 }{ 1 }, false, 'ReadTiming', ~hDI.SkipPreRouteTimingAnalysis );
elseif strcmpi( workflowSteps{ 1 }{ 1 }, 'PAR' )
[ parsedResults, metadata ] = parserObj.readResults( workflowSteps{ 1 }{ 1 }, false, 'ReadTiming', true );
else 
return ;
end 




resourceVariables = { metadata.combALUTStr;metadata.logicRegStr;metadata.DSPsStr };

usage = [ parsedResults.CombALUTs, parsedResults.LogicRegisters, parsedResults.DSPs ];


availableResources = [ nan, parsedResults.MaxLogicRegisters, parsedResults.MaxDSPs ];

if ~isnan( parsedResults.M9Ks )
resourceVariables = [ resourceVariables;{ metadata.M9KsStr } ];
usage = [ usage, parsedResults.M9Ks ];
availableResources = [ availableResources, parsedResults.MaxM9Ks ];
end 
if ~isnan( parsedResults.M10Ks )
resourceVariables = [ resourceVariables;{ metadata.M10KsStr } ];
usage = [ usage, parsedResults.M10Ks ];
availableResources = [ availableResources, parsedResults.MaxM10Ks ];
end 
if ~isnan( parsedResults.M20Ks )
resourceVariables = [ resourceVariables;{ metadata.M20KsStr } ];
usage = [ usage, parsedResults.M20Ks ];
availableResources = [ availableResources, parsedResults.MaxM20Ks ];
end 
if ~isnan( parsedResults.M144Ks )
resourceVariables = [ resourceVariables;{ metadata.M144KsStr } ];
usage = [ usage, parsedResults.M144Ks ];
availableResources = [ availableResources, parsedResults.MaxM144Ks ];
end 


utilization = ( usage ./ availableResources ) .* 100;

hardwareResults.ResourceVariables = resourceVariables;
hardwareResults.ResourceData = formatData( usage, '%d' );
hardwareResults.AvailableResources = formatData( availableResources, '%d' );
hardwareResults.Utilization = formatData( utilization, '%.2f' );
hardwareResults.ResourceFile = metadata.RPTFileName;




isQuartus = true;
[ timingVariables, timingData ] = getTimingData( hDI, metadata, parsedResults, isQuartus );

hardwareResults.TimingVariables = timingVariables;
hardwareResults.TimingData = timingData;
hardwareResults.TimingFile = metadata.TQRFileName;
hardwareResults.Slack = parsedResults.Slack;
catch 
hardwareResults = [  ];
end 
end 

function hardwareResults = parseQuartusProReports( hDI, projectName, projectDir, workflowSteps )


hardwareResults = [  ];
try 



dutName = projectName( 1:end  - 5 );

parserObj = HDLReadStatistics( dutName, 'TargetDir', projectDir, 'SynthTool', 'Intel Quartus Pro' );






if strcmpi( workflowSteps{ 1 }{ 1 }, 'Map' )

[ parsedResults, metadata ] = parserObj.readResults( workflowSteps{ 1 }{ 1 }, false, 'ReadTiming', ~hDI.SkipPreRouteTimingAnalysis );
elseif strcmpi( workflowSteps{ 1 }{ 1 }, 'PAR' )
[ parsedResults, metadata ] = parserObj.readResults( workflowSteps{ 1 }{ 1 }, false, 'ReadTiming', true );
else 
return ;
end 




resourceVariables = { metadata.combALUTStr;metadata.logicRegStr;metadata.DSPsStr };

usage = [ parsedResults.CombALUTs, parsedResults.LogicRegisters, parsedResults.DSPs ];


availableResources = [ nan, parsedResults.MaxLogicRegisters, parsedResults.MaxDSPs ];

if ~isnan( parsedResults.M9Ks )
resourceVariables = [ resourceVariables;{ metadata.M9KsStr } ];
usage = [ usage, parsedResults.M9Ks ];
availableResources = [ availableResources, parsedResults.MaxM9Ks ];
end 
if ~isnan( parsedResults.M10Ks )
resourceVariables = [ resourceVariables;{ metadata.M10KsStr } ];
usage = [ usage, parsedResults.M10Ks ];
availableResources = [ availableResources, parsedResults.MaxM10Ks ];
end 
if ~isnan( parsedResults.M20Ks )
resourceVariables = [ resourceVariables;{ metadata.M20KsStr } ];
usage = [ usage, parsedResults.M20Ks ];
availableResources = [ availableResources, parsedResults.MaxM20Ks ];
end 
if ~isnan( parsedResults.M144Ks )
resourceVariables = [ resourceVariables;{ metadata.M144KsStr } ];
usage = [ usage, parsedResults.M144Ks ];
availableResources = [ availableResources, parsedResults.MaxM144Ks ];
end 


utilization = ( usage ./ availableResources ) .* 100;

hardwareResults.ResourceVariables = resourceVariables;
hardwareResults.ResourceData = formatData( usage, '%d' );
hardwareResults.AvailableResources = formatData( availableResources, '%d' );
hardwareResults.Utilization = formatData( utilization, '%.2f' );
hardwareResults.ResourceFile = metadata.RPTFileName;




isQuartus = true;
[ timingVariables, timingData ] = getTimingData( hDI, metadata, parsedResults, isQuartus );

hardwareResults.TimingVariables = timingVariables;
hardwareResults.TimingData = timingData;
hardwareResults.TimingFile = metadata.TQRFileName;
hardwareResults.Slack = parsedResults.Slack;
catch 
hardwareResults = [  ];
end 
end 

function formattedData = formatData( rawData, formatStr )
if nargin < 2
formatStr = '%0.5g';
end 

formattedData = cell( numel( rawData ), 1 );
for ii = 1:numel( rawData )
if isnan( rawData( ii ) ) || isinf( rawData( ii ) )
formattedData{ ii } = ' ';
else 
formattedData{ ii } = num2str( rawData( ii ), formatStr );
end 
end 
end 

function [ timingVariables, timingData ] = getTimingData( hDI, metadata, parsedResults, isQuartus )

requirement = 1e3 / hDI.getTargetFrequency;


slack = parsedResults.Slack;

if isinf( requirement )

fmax = ' ';
else 
fmax = strcat( formatData( ( 1e3 ) ./ ( requirement - slack ), '%.2f' ), ' MHz' );
end 


if isQuartus
dataDelay = parsedResults.DataDelay;
timingVariables = { 'Requirement';metadata.dataDelayStr;metadata.slackStr;'Clock Frequency' };
else 

dataDelay = parsedResults.DataPathDelay;
timingVariables = { 'Requirement';metadata.dataPathDelayStr;metadata.slackStr;'Clock Frequency' };
end 


timingData = formatData( [ requirement, dataDelay, slack ] );
for ii = 1:numel( timingData )
tVar = timingData{ ii };
if ~isspace( tVar )
timingData{ ii } = strcat( tVar, ' ns' );
end 
end 

timingData = [ timingData;fmax ];

if ~isinf( requirement )

requirement_mhz = sprintf( '%d', hDI.getTargetFrequency );
timingData{ 1 } = strcat( timingData{ 1 }, ' (', requirement_mhz, ' MHz)' );
end 

end 
% Decoded using De-pcode utility v1.2 from file /tmp/tmpC5pzIF.p.
% Please follow local copyright laws when handling this file.

