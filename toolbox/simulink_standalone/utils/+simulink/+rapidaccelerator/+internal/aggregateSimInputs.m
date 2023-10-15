function simIn = aggregateSimInputs( simInputs, rtp, multisimInfo )

arguments
    simInputs Simulink.SimulationInput
    rtp
    multisimInfo
end

simIn = simInputs( 1 );
defaultRtpParam = rtp.parameters;
numSims = length( simInputs );


if ~iscell( rtp.parameters )
    rtp.parameters = { defaultRtpParam };
end

for i = numSims: - 1:1
    varTuned = false;
    nVar = numel( simInputs( i ).Variables );
    for j = 1:nVar
        try
            rtp = Simulink.BlockDiagram.modifyTunableParameters(  ...
                rtp,  ...
                i,  ...
                simInputs( i ).Variables( j ).Name,  ...
                simInputs( i ).Variables( j ).Value );
            varTuned = true;
        catch ME
            switch ME.identifier
                case 'RTW:rsim:SetRTPParamBadIdentifier'

                otherwise
                    throw( ME )
            end
        end
    end


    if ~varTuned
        rtp.parameters{ i } = defaultRtpParam;
    end
    multisimInfo.runInfo( i ).RunId = simInputs( i ).RunId;
    multisimInfo.runInfo( i ).simInput = simInputs( i );
end

simIn = simIn.addHiddenModelParameter( 'RapidAcceleratorMultiSim', multisimInfo );
simIn = simIn.setModelParameter( 'RapidAcceleratorParameterSets', rtp );
simIn.Variables = [  ];
simIn.PostSimFcn = [  ];
end


