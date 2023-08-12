function live_simulation( onoff, varargin )










LogicalStr = { 'Off', 'On' };
params = inputParser;
addOptional( params, 'qos', [  ] );

parse( params, varargin{ : } );
if strcmpi( onoff, 'on' )
disp( 'Enabling Live Simulation' );
slfeature( 'LiveSimulation', 1 );
slfeature( 'SimulinkDataEvents', 2 );
elseif strcmpi( onoff, 'off' )
disp( 'Disabling Live Simulation' );
slfeature( 'SimulinkDataEvents', 0 );
slfeature( 'LiveSimulation', 0 );
else 
current = slfeature( 'LiveSimulation' ) > 0;
disp( [ 'Live Simulation: ', LogicalStr{ current + 1 } ] );
end 

if slfeature( 'LiveSimulation' ) > 0
if strcmpi( params.Results.qos, 'on' )
disp( 'Enabling QoS options' );
slfeature( 'SimulinkDataEvents', 3 );
elseif strcmpi( params.Results.qos, 'off' )
disp( 'Disabling QoS options' );
slfeature( 'SimulinkDataEvents', 2 );
else 
current = slfeature( 'SimulinkDataEvents' ) > 1;
disp( [ 'QoS options: ', LogicalStr{ current + 1 } ] );
end 
end 

end 

% Decoded using De-pcode utility v1.2 from file /tmp/tmpSutVip.p.
% Please follow local copyright laws when handling this file.

