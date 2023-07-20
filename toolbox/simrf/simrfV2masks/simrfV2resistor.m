function simrfV2resistor(block,action)





    top_sys=bdroot(block);
    if strcmpi(get_param(top_sys,'BlockDiagramType'),'library')&&...
        strcmpi(top_sys,'simrfV2elements')
        return
    end




    switch(action)
    case 'simrfInit'
        top_sys=bdroot(block);

        if regexpi(get_param(top_sys,'SimulationStatus'),...
            '^(updating|initializing)$')

            MaskWSValues=simrfV2getblockmaskwsvalues(block);


            validateattributes(MaskWSValues.Resistance,{'numeric'},...
            {'nonempty','scalar','real','nonnegative','finite'},'',...
            'Resistance');
            set_param([block,'/R_NOISE_RF'],...
            'R',num2str(MaskWSValues.Resistance,16),...
            'R_unit',MaskWSValues.Resistance_unit);
        end

    end

end