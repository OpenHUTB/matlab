function simrfV2mutualinductor(block,action)






    top_sys=bdroot(block);
    if strcmpi(get_param(top_sys,'BlockDiagramType'),'library')&&...
        strcmpi(top_sys,'simrfV2elements')
        return
    end




    switch(action)
    case 'simrfInit'

        if regexpi(get_param(top_sys,'SimulationStatus'),...
            '^(updating|initializing|stopped)$')

            MaskWSValues=simrfV2getblockmaskwsvalues(block);


            validateattributes(MaskWSValues.L1,{'numeric'},...
            {'nonempty','scalar','positive','finite'},block,...
            'Mutual Inductor L1');
            validateattributes(MaskWSValues.L2,{'numeric'},...
            {'nonempty','scalar','positive','finite'},block,...
            'Mutual Inductor L2');
            validateattributes(MaskWSValues.K,{'numeric'},...
            {'nonempty','scalar','finite','>',-1,'<',1},block,...
            'Coefficient of coupling');
            set_param([block,'/MUTUAL_INDUCTOR_RF'],...
            'L1',num2str(MaskWSValues.L1,16),...
            'L1_unit',MaskWSValues.L1_unit,...
            'L2',num2str(MaskWSValues.L2,16),...
            'L2_unit',MaskWSValues.L2_unit,...
            'K',num2str(MaskWSValues.K,16))
        end
    end

end