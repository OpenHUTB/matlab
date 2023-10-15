function [ fcn, data ] = getFcnAndSource( fcn, signalSource, portSignalSource, blockSignalSource )
arguments
    fcn function_handle

    signalSource.UserData{ slsim.SignalSource.validateUserData( signalSource.UserData ) }
    signalSource.BlockPath ...
        { slsim.SignalSource.validateBlockPath( signalSource.BlockPath ) }
    signalSource.BusElement ...
        { slsim.SignalSource.validateBusElement( signalSource.BusElement ) }
    portSignalSource.PortName ...
        { slsim.PortSignalSource.validatePortName( portSignalSource.PortName ) }
    portSignalSource.Element ...
        { slsim.PortSignalSource.validateElement( portSignalSource.Element ) }
    portSignalSource.Port ...
        { slsim.PortSignalSource.validatePort( portSignalSource.Port ) }
    blockSignalSource.Outport ...
        { slsim.BlockSignalSource.validateOutport( blockSignalSource.Outport ) }
end


if ~isempty( fieldnames( portSignalSource ) ) && ~isempty( fieldnames( blockSignalSource ) )
    msgId = 'SimulinkExecution:SimulationService:BlockAndPortSpecsNotAllowed';
    me = MException( msgId, message( msgId ).getString(  ) );
    throwAsCaller( me );
end

data = mergeStructs( signalSource, portSignalSource, blockSignalSource );


if ( isempty( fieldnames( data ) ) )
    msgId = 'SimulinkExecution:SimulationService:NoSignalSourceSpecified';
    me = MException( msgId, message( msgId ).getString(  ) );
    throwAsCaller( me );
end
end

function val = mergeStructs( varargin )

val = struct(  );
nStructs = numel( varargin );

for idx = 1:nStructs
    structVal = varargin{ idx };
    if isempty( structVal )
        continue ;
    end
    fields = fieldnames( structVal );
    nFields = numel( fields );
    for fIdx = 1:nFields
        val.( fields{ fIdx } ) = structVal.( fields{ fIdx } );
    end
end
end
