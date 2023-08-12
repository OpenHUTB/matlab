function job = batchsimWithClusterArgument( clusterObj, simIns, varargin, config )





R36
clusterObj( 1, 1 )parallel.Cluster
simIns Simulink.SimulationInput{ mustBeNonempty }
end 

R36( Repeating )
varargin
end 

R36
config.BatchSimFcn( 1, 1 )function_handle = @MultiSim.internal.batchsim
end 

errorOutIfProfileWasSpecified( varargin{ : } );
job = config.BatchSimFcn( simIns, varargin{ : }, 'Profile', clusterObj );
end 

function errorOutIfProfileWasSpecified( varargin )
p = inputParser;
addParameter( p, 'Profile', parallel.defaultProfile );
p.KeepUnmatched = true;
parse( p, varargin{ : } );

if ~ismember( 'Profile', p.UsingDefaults )
error( message( 'Simulink:batchsim:ProfileUsedWithClusterObject' ) );
end 
end 

% Decoded using De-pcode utility v1.2 from file /tmp/tmpWLuirb.p.
% Please follow local copyright laws when handling this file.

