function simrfV2idealtransformer(block,action)






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


            validateattributes(MaskWSValues.n,{'numeric'},...
            {'nonempty','scalar','positive','finite'},block,...
            'Ideal Transformer');
        end
    end

end