function simrfcombos=simrfV2_mask_combos(model,param)




    switch model
    case 'transmission_line_rf'
        switch param
        case 'model_type'
            simrfcombos.Entries={
            'Delay-based and lossless',...
            'Delay-based and lossy',...
            'Lumped parameter L-section',...
            'Lumped parameter Pi-section'};
            simrfcombos.Values=[1,2,3,4];
            simrfcombos.MapValues={'1','2','3','4'};
            simrfcombos.Callback='';
        case 'LC_param'
            simrfcombos.Entries={...
            'By characteristic impedance and capacitance',...
            'By inductance and capacitance'};
            simrfcombos.Values=[1,2];
            simrfcombos.MapValues={'1','2'};
            simrfcombos.Callback='';
        otherwise
            error(message('simrf:simrfV2errors:BadParamValues',...
            'Combo switch',model,param))
        end
    otherwise
        error(message('simrf:simrfV2errors:BadParamValues',...
        'Combo switch',model,'Unknown'))
    end

end

