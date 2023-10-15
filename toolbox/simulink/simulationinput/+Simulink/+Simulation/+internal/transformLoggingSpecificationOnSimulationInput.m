function simInput = transformLoggingSpecificationOnSimulationInput( simInput )

arguments
    simInput( 1, 1 )Simulink.SimulationInput
end

if ~isempty( simInput.LoggingSpecification )
    sigs = simInput.LoggingSpecification.SignalsToLog;
    if ~isempty( sigs )
        validSignals = true( 1, numel( sigs ) );
        for ct = 1:numel( sigs )
            subPath = sigs( ct ).BlockPath.SubPath;
            if isempty( subPath )
                bPath = sigs( ct ).BlockPath.convertToCell;
                modelNameFromBlockPath = strtok( bPath, "/" );
                load_system( modelNameFromBlockPath );
                portHandles = get_param( bPath{ end  }, 'PortHandles' );

                if sigs( ct ).OutputPortIndex > numel( portHandles.Outport )
                    validSignals( ct ) = false;
                    continue ;
                end

                ph = portHandles.Outport( sigs( ct ).OutputPortIndex );
                if sigs( ct ).LoggingInfo.DataLogging && strcmp( get_param( ph, 'DataLogging' ), 'off' )

                    simInput = simInput.setPortParameter( ph, 'DataLogging', 'on' );
                end
            else


                blockPath = sigs( ct ).BlockPath.convertToCell;
                if numel( blockPath ) > 1
                    strPath = strcat( '{', blockPath{ 1 } );
                    for ctPath = 2:numel( blockPath )
                        strPath = sprintf( '%s, %s', strPath, blockPath{ ctPath } );
                    end
                    strPath = strcat( strPath, '}' );
                else
                    strPath = blockPath{ 1 };
                end

                ME = MException( message( 'Simulink:Commands:MultiSimCannotLogSignal', strPath, subPath ) );
                simInput.reportAsWarning( ME );
            end
        end

        invalidSignals = sigs( ~validSignals );
        if ~isempty( invalidSignals )
            simInput.LoggingSpecification.removeSignalsToLog( invalidSignals );
        end

        if any( validSignals )

            simInput = simInput.addHiddenModelParameter( 'DataLoggingOverride',  ...
                simInput.LoggingSpecification.getSignalsToLog( simInput.ModelName ) );


            simInput = simInput.addHiddenModelParameter( 'SignalLogging', 'on' );
        end
    end
end
simInput.LoggingSpecification = [  ];
end

