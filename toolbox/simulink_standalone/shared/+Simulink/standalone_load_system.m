function handle = standalone_load_system( sys )

arguments
    sys{ mustBeText };
end

if ischar( sys )
    handle = load_single_system( sys );
else
    handle = zeros( size( sys ) );
    for i = 1:numel( sys )
        handle( i ) = load_single_system( sys( i ) );
    end
end

end

function sys_handle = load_single_system( sys_path )

if ( iscell( sys_path ) )
    sys_path = cell2mat( sys_path );
end

if isempty( sys_path )
    ME = MException( 'SimulinkStandalone:Parameters:InvSimulinkObjectName',  ...
        message( 'SimulinkStandalone:Parameters:InvSimulinkObjectName', sys_path ) );
    throwAsCaller( ME );
end

if contains( sys_path, '/' )
    ME = MException( 'SimulinkStandalone:Parameters:InvalidInputToLoadSystem',  ...
        message( 'SimulinkStandalone:Parameters:InvalidInputToLoadSystem' ) );
    throwAsCaller( ME );
end

modelInterface = Simulink.RapidAccelerator.getStandaloneModelInterface( sys_path );
modelInterface.initializeForDeployment(  );
modelInterface.debugLog( 2, [ 'load_system(''', sys_path, ''') called ' ] );
sys_handle = modelInterface.get_param( 'handle' );

end


