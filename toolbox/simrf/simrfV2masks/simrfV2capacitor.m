function simrfV2capacitor(block,action)





    top_sys=bdroot(block);
    if strcmpi(get_param(top_sys,'BlockDiagramType'),'library')&&...
        strcmpi(top_sys,'simrfV2elements')
        return
    end




    switch(action)
    case 'simrfInit'

        if regexpi(get_param(top_sys,'SimulationStatus'),...
            '^(updating|initializing)$')

            MaskWSValues=simrfV2getblockmaskwsvalues(block);


            validateattributes(MaskWSValues.Capacitance,{'numeric'},...
            {'nonempty','scalar','real','nonnegative','finite'},...
            block,'Capacitance');
            set_param([block,'/CAPACITOR_RF'],'Capacitance',...
            num2str(MaskWSValues.Capacitance,16),...
            'Capacitance_unit',MaskWSValues.Capacitance_unit)
        end
    end

end