function job = batchsim( simInsOrClusterObj, varargin, options, config )


















R36
simInsOrClusterObj
end 

R36( Repeating )
varargin
end 

R36
options.ThrowAsCaller( 1, 1 )logical = true
config.BatchSimFcn( 1, 1 )function_handle = @MultiSim.internal.batchsim
config.BatchSimWithClusterArgFcn( 1, 1 )function_handle = @MultiSim.internal.batchsimWithClusterArgument
end 




if ( nargin > 1 && isa( varargin{ 1 }, 'parallel.Cluster' ) )
error( message( 'Simulink:batchsim:ClusterMustBeFirstArgument' ) );
end 

if isa( simInsOrClusterObj, 'parallel.Cluster' )
batchsimFcn = config.BatchSimWithClusterArgFcn;
else 
batchsimFcn = config.BatchSimFcn;
end 

try 
job = batchsimFcn( simInsOrClusterObj, varargin{ : } );
catch ME
if options.ThrowAsCaller
throwAsCaller( ME )
else 
rethrow( ME );
end 
end 
end 
% Decoded using De-pcode utility v1.2 from file /tmp/tmpjWjSIJ.p.
% Please follow local copyright laws when handling this file.

