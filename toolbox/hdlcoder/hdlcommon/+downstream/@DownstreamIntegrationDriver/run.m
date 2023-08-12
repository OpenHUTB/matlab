function [ status, result, warnMsg, hardwareResults ] = run( obj, varargin )











warnMsg = '';

hardwareResults = [  ];

action = varargin{ 1 };
if strcmpi( action, 'Simulation' )

[ status, result ] = obj.hSimulationToolDriver.run;
else 

if strcmpi( obj.get( 'Tool' ), obj.EmptyToolStr )
error( message( 'hdlcommon:workflow:SynthesisToolNotSpecified' ) );
elseif strcmpi( obj.get( 'Tool' ), obj.NoAvailableToolStr )
error( message( 'hdlcommon:workflow:NoAvailableTool' ) );
elseif obj.isHLSWorkflow
[ status, result ] = obj.runHLSSynthesis;
else 
[ status, result ] = obj.hToolDriver.hEngine.run( varargin{ : } );

if strcmp( obj.get( 'Workflow' ), obj.GenericWorkflowStr )


hardwareResults = obj.parseToolReports( varargin{ : } );
end 


if strcmpi( obj.get( 'Tool' ), 'Xilinx ISE' ) &&  ...
isequal( varargin{ 1 }, { 'PAR', 'PostPARTiming' } )

parReportPath = obj.getPARReportPath;
parReportStr = fileread( parReportPath );
timingSearch1 = regexp( parReportStr, '[1-9] constraints? not met\.', 'once' );
timingSearch2 = regexp( parReportStr, 'Your design did not meet timing', 'once' );
if ~isempty( timingSearch1 ) || ~isempty( timingSearch2 )
parPathLink = hdlgetfilelink( obj.getPARReportPath );
warnobj = message( 'hdlcommon:workflow:WarnAboutTiming', parPathLink );
warnMsg = warnobj.getString;
end 
end 
end 
end 
% Decoded using De-pcode utility v1.2 from file /tmp/tmpEFQhnO.p.
% Please follow local copyright laws when handling this file.

