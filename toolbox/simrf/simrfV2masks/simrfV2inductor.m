function simrfV2inductor(block,action)





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


            validateattributes(MaskWSValues.Inductance,{'numeric'},...
            {'nonempty','scalar','real','nonnegative','finite'},...
            block,'Inductance');
            set_param([block,'/INDUCTOR_RF'],'Inductance',...
            num2str(MaskWSValues.Inductance,16),...
            'Inductance_unit',MaskWSValues.Inductance_unit)
        end
    end

end