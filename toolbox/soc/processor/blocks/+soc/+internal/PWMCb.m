function varargout = PWMCb( func, blkH, varargin )




if nargout == 0
feval( func, blkH, varargin{ : } );
else 
[ varargout{ 1:nargout } ] = feval( func, blkH, varargin{ : } );
end 
end 



function LoadFcn( blkH )
if soc.blkcb.cbutils( 'IsLibContext', blkH ), return ;end 
end 

function MaskParamCb( paramName, blkH )
cbH = eval( [ '@', paramName, 'Cb' ] );
soc.blkcb.cbutils( 'MaskParamCb', paramName, blkH, cbH )
end 

function MaskInitFcn( blkH )%#ok<*DEFNU>
blkPath = [ get( blkH, 'Path' ), '/', get( blkH, 'Name' ) ];
blkP = soc.blkcb.cbutils( 'GetDialogParams', blkH, 'slResolve' );




ShowInvPWMPort = get_param( blkH, 'OutSigMode' );

interfaceChange = false;

switch ShowInvPWMPort
case 'Switching'
if ( ~strcmpi( get_param( [ blkPath, '/~PWM' ], 'BlockType' ), 'outport' ) )
interfaceChange = true;
newdblk = replace_block( [ blkPath, '/~PWM' ], 'Terminator', 'Outport', 'noprompt' );
assert( ~isempty( newdblk ), message( 'soc:msgs:InternalNoNewBlkFor', '~PWM outport' ) );
set_param( newdblk{ 1 }, 'Name', '~PWM' );
set_param( newdblk{ 1 }, 'Port', '2' )
end 
case 'Average'
if ( ~strcmpi( get_param( [ blkPath, '/~PWM' ], 'BlockType' ), 'Terminator' ) )
interfaceChange = true;
newdblk = replace_block( [ blkPath, '/~PWM' ], 'Outport', 'Terminator', 'noprompt' );
assert( ~isempty( newdblk ), message( 'soc:msgs:InternalNoNewBlkFor', 'Event terminator' ) );
set_param( newdblk{ 1 }, 'Name', '~PWM' );
end 
end 
function EventportH = l_eventPort_out( blkH, blkPath, EventPortStr )
blkportH = get_param( blkH, 'PortHandles' );
if strcmp( get_param( [ blkPath, '/', EventPortStr ], 'BlockType' ), 'Outport' )
EventportH = blkportH.Outport( end  );
else 
EventportH = [  ];
end 
end 

NumEventReplication = get_param( blkH, 'NumADCSOCReplica' );
hEventOutMode = [ blkPath, '/Variant/SIM/NumEventControl' ];
labelName = [ 'event', NumEventReplication ];
set_param( hEventOutMode, 'LabelModeActiveChoice', labelName );
numEvents = str2double( NumEventReplication );
dBlkPath = [ blkPath, '/Variant' ];
commonargs = { 'Regexp', 'on', 'LookUnderMasks', 'all', 'FollowLinks', 'on', 'SearchDepth', 1 };
allOutPorts = find_system( blkPath, commonargs{ : }, 'BlockType', 'Outport', 'PortName', '^trigger*' );
allOutTerms = find_system( blkPath, commonargs{ : }, 'BlockType', 'Terminator', 'PortName', '^trigger*' );
numAllOutPorts = length( allOutPorts );
numAllOutTerms = length( allOutTerms );

if ( numAllOutPorts > 0 )
if numEvents > numAllOutPorts
interfaceChange = true;

for id = numAllOutPorts + 1:numEvents
portName = [ 'trigger', num2str( id - 1 ) ];
portPath = [ blkPath, '/', portName ];
if strcmpi( get_param( portPath, 'BlockType' ), 'Terminator' )
newdblk = replace_block( portPath, 'Terminator', 'Outport', 'noprompt' );
assert( ~isempty( newdblk ), message( 'soc:msgs:InternalNoNewBlkFor', 'outport' ) );
set_param( newdblk{ 1 }, 'Name', portName );
end 
end 
elseif numEvents < numAllOutPorts
interfaceChange = true;


for id = numEvents + 1:numAllOutPorts

portName = [ 'trigger', num2str( id - 1 ) ];
portPath = [ blkPath, '/', portName ];
if strcmpi( get_param( portPath, 'BlockType' ), 'Outport' )
newdblk = replace_block( portPath, 'Outport', 'Terminator', 'noprompt' );
assert( ~isempty( newdblk ), message( 'soc:msgs:InternalNoNewBlkFor', 'Terminator' ) );
set_param( newdblk{ 1 }, 'Name', portName );
end 
end 
else 

end 
end 
ShowInterruptPort = get_param( blkH, 'EventType' );
portName = 'interrupt';
portPath = [ blkPath, '/', portName ];
if strcmpi( ShowInterruptPort, 'PWM interrupt' )
if strcmpi( get_param( portPath, 'BlockType' ), 'Terminator' )
newdblk = replace_block( portPath, 'Terminator', 'Outport', 'noprompt' );
assert( ~isempty( newdblk ), message( 'soc:msgs:InternalNoNewBlkFor', 'Interrupt Terminator' ) );
end 
for id = 1:numEvents

if ( id == 1 )
portName = 'trigger';
else 
portName = [ 'trigger', num2str( id - 1 ) ];
end 
portPath = [ blkPath, '/', portName ];
if strcmpi( get_param( portPath, 'BlockType' ), 'Outport' )
newdblk = replace_block( portPath, 'Outport', 'Terminator', 'noprompt' );
assert( ~isempty( newdblk ), message( 'soc:msgs:InternalNoNewBlkFor', 'event Outport' ) );
set_param( newdblk{ 1 }, 'Name', portName );
end 
end 
elseif strcmpi( ShowInterruptPort, 'PWM interrupt' ) ||  ...
strcmpi( ShowInterruptPort, 'ADC start and PWM interrupt' )
if strcmpi( get_param( portPath, 'BlockType' ), 'Terminator' )
newdblk = replace_block( portPath, 'Terminator', 'Outport', 'noprompt' );
assert( ~isempty( newdblk ), message( 'soc:msgs:InternalNoNewBlkFor', 'Interrupt Terminator' ) );
end 
for id = 1:numEvents

if ( id == 1 )
portName = 'trigger';
else 
portName = [ 'trigger', num2str( id - 1 ) ];
end 
portPath = [ blkPath, '/', portName ];
if strcmpi( get_param( portPath, 'BlockType' ), 'Terminator' )
newdblk = replace_block( portPath, 'Terminator', 'Outport', 'noprompt' );
assert( ~isempty( newdblk ), message( 'soc:msgs:InternalNoNewBlkFor', 'event Terminator' ) );
set_param( newdblk{ 1 }, 'Name', portName );
end 
end 
end 
if strcmpi( ShowInterruptPort, 'ADC start' )
if strcmpi( get_param( portPath, 'BlockType' ), 'Outport' )
newdblk = replace_block( portPath, 'Outport', 'Terminator', 'noprompt' );
assert( ~isempty( newdblk ), message( 'soc:msgs:InternalNoNewBlkFor', 'Interrupt Outport' ) );
end 
for id = 1:numEvents

if ( id == 1 )
portName = 'trigger';
else 
portName = [ 'trigger', num2str( id - 1 ) ];
end 
portPath = [ blkPath, '/', portName ];
if strcmpi( get_param( portPath, 'BlockType' ), 'Terminator' )
newdblk = replace_block( portPath, 'Terminator', 'Outport', 'noprompt' );
assert( ~isempty( newdblk ), message( 'soc:msgs:InternalNoNewBlkFor', 'event Terminator' ) );
set_param( newdblk{ 1 }, 'Name', portName );
end 
end 
end 
ShowDirPort = get_param( blkH, 'OutCountDir' );
portName = 'direction';
portPath = [ blkPath, '/', portName ];
if strcmpi( ShowDirPort, 'on' )
if strcmpi( get_param( portPath, 'BlockType' ), 'Terminator' )
newdblk = replace_block( portPath, 'Terminator', 'Outport', 'noprompt' );
assert( ~isempty( newdblk ), message( 'soc:msgs:InternalNoNewBlkFor', 'Direction Terminator' ) );
end 
else 
if strcmpi( get_param( portPath, 'BlockType' ), 'Outport' )
newdblk = replace_block( portPath, 'Outport', 'Terminator', 'noprompt' );
assert( ~isempty( newdblk ), message( 'soc:msgs:InternalNoNewBlkFor', 'Direction Outport' ) );
end 
end 



if interfaceChange


pos = get_param( blkPath, 'Position' );
set_param( blkPath, 'Position', pos - [ 10, 10, 20, 20 ] );
set_param( blkPath, 'Position', pos );
end 


blkP = soc.blkcb.cbutils( 'GetDialogParams', blkH, 'slResolve' );%#ok<NASGU>
l_SetMaskDisplay( blkH );

l_SetMaskHelp( blkH );
soc.internal.setBlockIcon( blkH, 'socicons.PWMInterface' );




Tp = evalin( 'base', get_param( blkH, 'Period' ) );
topDelay = evalin( 'base', get_param( blkH, 'DeadTimeTopPWM' ) );


set_param( blkH, 'DeadTimeBottomPWM', get_param( blkH, 'DeadTimeTopPWM' ) );
botDelay = evalin( 'base', get_param( blkH, 'DeadTimeBottomPWM' ) );


validateattributes( blkP.Period, { 'numeric' }, { 'real', 'nonnan', 'finite', 'nonempty', 'scalar', '>', 0 }, '', 'PWM waveform period' );
validateattributes( blkP.DeadTimeTopPWM, { 'numeric' }, { 'real', 'nonnan', 'finite', 'nonempty', 'scalar', '>=', 0 }, '', 'Dead time' );
validateattributes( blkP.DeadTimeBottomPWM, { 'numeric' }, { 'real', 'nonnan', 'finite', 'nonempty', 'scalar', '>=', 0 }, '', 'Dead time' );
validateattributes( blkP.PhaseOffset, { 'numeric' }, { 'real', 'nonnan', 'finite', 'nonempty', 'scalar', '>=', 0 }, '', 'Phase offset' );
validateattributes( blkP.PhaseOffset, { 'numeric' }, { 'real', 'nonnan', 'finite', 'nonempty', 'scalar', '<', 360 }, '', 'Phase offset' );

PWMSfunc_blkp = [ blkPath, '/Variant/SIM/Switching/PWM SIM' ];
set_param( PWMSfunc_blkp, 'Period', num2str( blkP.Period ) );
set_param( PWMSfunc_blkp, 'DeadTimeTopPWM', num2str( blkP.DeadTimeTopPWM ) );
set_param( PWMSfunc_blkp, 'DeadTimeBottomPWM', num2str( blkP.DeadTimeBottomPWM ) );


if ( ( topDelay > ( Tp / 10 ) ) || ( botDelay > ( Tp / 10 ) ) )
errorID = message( 'soc:iosim:DeadTimeTooHigh' );
error( errorID.getString );
end 


end 

function EventportH = l_eventPort( blkH, blkPath, EventPortStr )
blkportH = get_param( blkH, 'PortHandles' );
if strcmpi( get_param( [ blkPath, '/', EventPortStr ], 'BlockType' ), 'Outport' )
EventportH = blkportH.Outport( end  );
else 
EventportH = [  ];
end 
end 

function l_SetMaskHelp( blkH )

helpcmd = 'eval(''soc.internal.helpview(''''soc_pwminterface'''')'')';
set_param( blkH, 'MaskHelp', helpcmd );
end 

function l_SetMaskDisplay( blkH )
inPort = sprintf( 'port_label(''input'',1, ''msg'')' );
blkPath = [ get( blkH, 'Path' ), '/', get( blkH, 'Name' ) ];
commonargs = { 'Regexp', 'on', 'LookUnderMasks', 'all', 'FollowLinks', 'on', 'SearchDepth', 1 };

allOutPorts = find_system( blkPath, commonargs{ : }, 'BlockType', 'Outport' );

numOut = length( allOutPorts );
outputLabels = cell( numOut * 2, 1 );
outputLabels( 1:2:end  ) = cellfun( @str2num, get_param( allOutPorts, 'Port' ), 'UniformOutput', false );
outputLabels( 2:2:end  ) = get_param( allOutPorts, 'Name' );
outputLabels( 2:2:end  ) = strrep( outputLabels( 2:2:end  ), 'trigger', 'event' );

if ( strcmpi( get_param( blkH, 'OutSigMode' ), 'Average' ) )
outPort1 = sprintf( 'port_label(''output'',1, ''dCycle'')' );
outPorts = sprintf( 'port_label(''output'', %d, ''%s'');\n', outputLabels{ 3:end  } );

fullLabel = sprintf( '\n %s;\n %s; \n %s',  ...
inPort, outPort1, outPorts );
set_param( blkH, 'MaskDisplay', fullLabel );
else 
outPort1 = sprintf( 'port_label(''output'',1, ''PWM'')' );
outPort2 = sprintf( 'port_label(''output'',2, ''\\simPWM'', ''texmode'', ''on'')' );
outPorts = sprintf( 'port_label(''output'', %d, ''%s'');\n', outputLabels{ 5:end  } );
fullLabel = sprintf( '\n %s;\n %s;\n %s;\n %s',  ...
inPort, outPort1, outPort2, outPorts );
set_param( blkH, 'MaskDisplay', fullLabel );
end 
end 


function InitFcn( ~ )

if ~builtin( 'license', 'checkout', 'SoC_Blockset' )
error( message( 'soc:utils:NoLicense' ) );
end 

soc.internal.HWSWMessageTypeDef(  );
end 


function [ vis, ens ] = EventTypeCb( blkH, val, vis, ens, idxMap )%#ok<INUSL>
switch val
case 'ADC start'
vis{ idxMap( 'EventCondition1' ) } = 'on';
vis{ idxMap( 'NumADCSOCReplica' ) } = 'on';
vis{ idxMap( 'NumADCSOCToWait' ) } = 'on';
vis{ idxMap( 'InterruptCond' ) } = 'off';
vis{ idxMap( 'NumInterruptToWait' ) } = 'off';
vis{ idxMap( 'IntLatency' ) } = 'off';
case 'PWM interrupt'
vis{ idxMap( 'InterruptCond' ) } = 'on';
vis{ idxMap( 'NumInterruptToWait' ) } = 'on';
vis{ idxMap( 'IntLatency' ) } = 'on';
vis{ idxMap( 'EventCondition1' ) } = 'off';
vis{ idxMap( 'NumADCSOCReplica' ) } = 'off';
vis{ idxMap( 'NumADCSOCToWait' ) } = 'off';
case 'ADC start and PWM interrupt'
vis{ idxMap( 'InterruptCond' ) } = 'on';
vis{ idxMap( 'NumInterruptToWait' ) } = 'on';
vis{ idxMap( 'IntLatency' ) } = 'on';
vis{ idxMap( 'EventCondition1' ) } = 'on';
vis{ idxMap( 'NumADCSOCReplica' ) } = 'on';
vis{ idxMap( 'NumADCSOCToWait' ) } = 'on';
end 
end 

function [ vis, ens ] = CounterModeCb( blkH, val, vis, ens, idxMap )
switch val
case 'Up'
ens{ idxMap( 'SamplingMode' ) } = 'on';
msk = Simulink.Mask.get( blkH );
p = msk.Parameters;
index = ismember( { p.Name }, 'SamplingMode' );
p( index ).TypeOptions = { 'End of PWM period', 'Immediate (at compare matches)' };
index = ismember( { p.Name }, 'EventCondition1' );
p( index ).TypeOptions = { 'End of PWM period', 'Compare 1', 'Compare 2' };
index = ismember( { p.Name }, 'InterruptCond' );
p( index ).TypeOptions = { 'End of PWM period', 'Compare 1', 'Compare 2' };
ens{ idxMap( 'EventCondition1' ) } = 'on';
vis{ idxMap( 'PWMAtCMP1UpCnt' ) } = 'off';
vis{ idxMap( 'PWMAtCMP1DwnCnt' ) } = 'off';
vis{ idxMap( 'PWMAtCMP2UpCnt' ) } = 'off';
vis{ idxMap( 'PWMAtCMP1UpCnt' ) } = 'off';
vis{ idxMap( 'PWMAtCMP2DwnCnt' ) } = 'off';
vis{ idxMap( 'PWMAtMidPeriod' ) } = 'off';
vis{ idxMap( 'PWMAtCMP1' ) } = 'on';
vis{ idxMap( 'PWMAtCMP2' ) } = 'on';
vis{ idxMap( 'OutCountDir' ) } = 'off';
case 'Down'
ens{ idxMap( 'SamplingMode' ) } = 'on';
ens{ idxMap( 'EventCondition1' ) } = 'on';
msk = Simulink.Mask.get( blkH );
p = msk.Parameters;
index = ismember( { p.Name }, 'SamplingMode' );
p( index ).TypeOptions = { 'End of PWM period', 'Immediate (at compare matches)' };
index = ismember( { p.Name }, 'EventCondition1' );
p( index ).TypeOptions = { 'End of PWM period', 'Compare 1', 'Compare 2' };
index = ismember( { p.Name }, 'InterruptCond' );
p( index ).TypeOptions = { 'End of PWM period', 'Compare 1', 'Compare 2' };
vis{ idxMap( 'PWMAtCMP1UpCnt' ) } = 'off';
vis{ idxMap( 'PWMAtCMP1DwnCnt' ) } = 'off';
vis{ idxMap( 'PWMAtCMP2UpCnt' ) } = 'off';
vis{ idxMap( 'PWMAtCMP1UpCnt' ) } = 'off';
vis{ idxMap( 'PWMAtCMP2DwnCnt' ) } = 'off';
vis{ idxMap( 'PWMAtMidPeriod' ) } = 'off';
vis{ idxMap( 'PWMAtCMP1' ) } = 'on';
vis{ idxMap( 'PWMAtCMP2' ) } = 'on';
vis{ idxMap( 'OutCountDir' ) } = 'off';
case 'Up-Down'
ens{ idxMap( 'SamplingMode' ) } = 'on';
msk = Simulink.Mask.get( blkH );
p = msk.Parameters;
index = ismember( { p.Name }, 'SamplingMode' );
p( index ).TypeOptions = { 'End of PWM period', 'Mid or End of PWM period', 'Immediate (at compare matches)' };
index = ismember( { p.Name }, 'EventCondition1' );
p( index ).TypeOptions = { 'End of PWM period', 'Mid of PWM period', 'Mid or End of PWM period', 'Compare 1 up count', 'Compare 1 down count', 'Compare 2 up count', 'Compare 2 down count' };
index = ismember( { p.Name }, 'InterruptCond' );
p( index ).TypeOptions = { 'End of PWM period', 'Mid of PWM period', 'Mid or End of PWM period', 'Compare 1 up count', 'Compare 1 down count', 'Compare 2 up count', 'Compare 2 down count' };
ens{ idxMap( 'EventCondition1' ) } = 'on';
vis{ idxMap( 'PWMAtCMP1UpCnt' ) } = 'on';
vis{ idxMap( 'PWMAtCMP1DwnCnt' ) } = 'on';
vis{ idxMap( 'PWMAtCMP2UpCnt' ) } = 'on';
vis{ idxMap( 'PWMAtCMP1UpCnt' ) } = 'on';
vis{ idxMap( 'PWMAtCMP2DwnCnt' ) } = 'on';
vis{ idxMap( 'PWMAtMidPeriod' ) } = 'on';
vis{ idxMap( 'PWMAtCMP1' ) } = 'off';
vis{ idxMap( 'PWMAtCMP2' ) } = 'off';
vis{ idxMap( 'OutCountDir' ) } = 'on';
end 
end 

function [ vis, ens ] = SamplingModeCb( blkH, val, vis, ens, idxMap )
blkPath = [ get( blkH, 'Path' ), '/', get( blkH, 'Name' ), '/Variant/SIM/Switching/PWM SIM' ];
samplingMode = get_param( blkH, 'SamplingMode' );
if ( matches( samplingMode, 'Immediate (at compare matches)' ) )
samplingMode = 'Immediate';
end 
set_param( blkPath, 'SamplingMode', samplingMode )
end 
% Decoded using De-pcode utility v1.2 from file /tmp/tmpdqGowT.p.
% Please follow local copyright laws when handling this file.

