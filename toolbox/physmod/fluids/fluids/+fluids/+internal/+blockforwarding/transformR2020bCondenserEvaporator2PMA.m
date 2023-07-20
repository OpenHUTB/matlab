function out=transformR2020bCondenserEvaporator2PMA(in)




    out=in;

    flow_arrangement=getValue(out,'flow_arrangement');
    if~isempty(flow_arrangement)
        flow_arrangement=replace(flow_arrangement,...
        'fluids.interfaces.heat_exchangers.condenser_evaporator_2P_MA_private.flow_arrangement',...
        'fluids.interfaces.heat_exchangers.enum.FlowArrangement2PMA');
        flow_arrangement=replace(flow_arrangement,'.parallel','.Parallel');
        flow_arrangement=replace(flow_arrangement,'.counter','.Counter');
        flow_arrangement=replace(flow_arrangement,'.cross','.Cross');
        out=setValue(out,'flow_arrangement',flow_arrangement);
    end

    cross_flow_arrangement=getValue(out,'cross_flow_arrangement');
    if~isempty(cross_flow_arrangement)
        cross_flow_arrangement=replace(cross_flow_arrangement,...
        'fluids.interfaces.heat_exchangers.condenser_evaporator_2P_MA_private.cross_flow_arrangement',...
        'fluids.interfaces.heat_exchangers.enum.CrossFlowArrangement2PMA');
        cross_flow_arrangement=replace(cross_flow_arrangement,'.mixed_mixed','.MixedMixed');
        cross_flow_arrangement=replace(cross_flow_arrangement,'.unmixed_unmixed','.UnmixedUnmixed');
        cross_flow_arrangement=replace(cross_flow_arrangement,'.mixed_unmixed','.MixedUnmixed');
        cross_flow_arrangement=replace(cross_flow_arrangement,'.unmixed_mixed','.UnmixedMixed');
        out=setValue(out,'cross_flow_arrangement',cross_flow_arrangement);
    end

    tube_cross_section_2P=getValue(out,'tube_cross_section_2P');
    if~isempty(tube_cross_section_2P)
        tube_cross_section_2P=replace(tube_cross_section_2P,...
        'fluids.interfaces.heat_exchangers.condenser_evaporator_2P_MA_private.tube_cross_section',...
        'fluids.interfaces.heat_exchangers.enum.TubeCrossSection');
        tube_cross_section_2P=replace(tube_cross_section_2P,'.circular','.Circular');
        tube_cross_section_2P=replace(tube_cross_section_2P,'.rectangular','.Rectangular');
        tube_cross_section_2P=replace(tube_cross_section_2P,'.annular','.Annular');
        tube_cross_section_2P=replace(tube_cross_section_2P,'.generic','.Generic');
        out=setValue(out,'tube_cross_section_2P',tube_cross_section_2P);
    end

    flow_geometry_MA=getValue(out,'flow_geometry_MA');
    if~isempty(flow_geometry_MA)
        flow_geometry_MA=replace(flow_geometry_MA,...
        'fluids.interfaces.heat_exchangers.condenser_evaporator_2P_MA_private.flow_geometry',...
        'fluids.interfaces.heat_exchangers.enum.FlowGeometryMA');
        flow_geometry_MA=replace(flow_geometry_MA,'.inside_tubes','.InsideTubes');
        flow_geometry_MA=replace(flow_geometry_MA,'.across_tube_banks','.AcrossTubeBank');
        flow_geometry_MA=replace(flow_geometry_MA,'.generic','.Generic');
        out=setValue(out,'flow_geometry_MA',flow_geometry_MA);
    end

    tube_cross_section_MA=getValue(out,'tube_cross_section_MA');
    if~isempty(tube_cross_section_MA)
        tube_cross_section_MA=replace(tube_cross_section_MA,...
        'fluids.interfaces.heat_exchangers.condenser_evaporator_2P_MA_private.tube_cross_section',...
        'fluids.interfaces.heat_exchangers.enum.TubeCrossSection');
        tube_cross_section_MA=replace(tube_cross_section_MA,'.circular','.Circular');
        tube_cross_section_MA=replace(tube_cross_section_MA,'.rectangular','.Rectangular');
        tube_cross_section_MA=replace(tube_cross_section_MA,'.annular','.Annular');
        tube_cross_section_MA=replace(tube_cross_section_MA,'.generic','.Generic');
        out=setValue(out,'tube_cross_section_MA',tube_cross_section_MA);
    end

    tube_pressure_loss_spec_MA=getValue(out,'tube_pressure_loss_spec_MA');
    if~isempty(tube_pressure_loss_spec_MA)
        tube_pressure_loss_spec_MA=replace(tube_pressure_loss_spec_MA,...
        'fluids.interfaces.heat_exchangers.condenser_evaporator_2P_MA_private.tube_pressure_loss_spec',...
        'fluids.interfaces.heat_exchangers.enum.TubePressureLossSpec');
        tube_pressure_loss_spec_MA=replace(tube_pressure_loss_spec_MA,'.loss_coeff','.LossCoeff');
        tube_pressure_loss_spec_MA=replace(tube_pressure_loss_spec_MA,'.haaland','.Haaland');
        out=setValue(out,'tube_pressure_loss_spec_MA',tube_pressure_loss_spec_MA);
    end

    tube_heat_coeff_spec_MA=getValue(out,'tube_heat_coeff_spec_MA');
    if~isempty(tube_heat_coeff_spec_MA)
        tube_heat_coeff_spec_MA=replace(tube_heat_coeff_spec_MA,...
        'fluids.interfaces.heat_exchangers.condenser_evaporator_2P_MA_private.tube_heat_coeff_spec',...
        'fluids.interfaces.heat_exchangers.enum.TubeHeatCoeffSpec');
        tube_heat_coeff_spec_MA=replace(tube_heat_coeff_spec_MA,'.colburn','.Colburn');
        tube_heat_coeff_spec_MA=replace(tube_heat_coeff_spec_MA,'.gneilinski','.Gneilinski');
        out=setValue(out,'tube_heat_coeff_spec_MA',tube_heat_coeff_spec_MA);
    end

    bank_arrangement_MA=getValue(out,'bank_arrangement_MA');
    if~isempty(bank_arrangement_MA)
        bank_arrangement_MA=replace(bank_arrangement_MA,...
        'fluids.interfaces.heat_exchangers.condenser_evaporator_2P_MA_private.bank_arrangement',...
        'fluids.interfaces.heat_exchangers.enum.BankArrangement');
        bank_arrangement_MA=replace(bank_arrangement_MA,'.inline','.Inline');
        bank_arrangement_MA=replace(bank_arrangement_MA,'.staggered','.Staggered');
        out=setValue(out,'bank_arrangement_MA',bank_arrangement_MA);
    end

    bank_pressure_loss_spec_MA=getValue(out,'bank_pressure_loss_spec_MA');
    if~isempty(bank_pressure_loss_spec_MA)
        bank_pressure_loss_spec_MA=replace(bank_pressure_loss_spec_MA,...
        'fluids.interfaces.heat_exchangers.condenser_evaporator_2P_MA_private.bank_pressure_loss_spec',...
        'fluids.interfaces.heat_exchangers.enum.BankPressureLossSpec');
        bank_pressure_loss_spec_MA=replace(bank_pressure_loss_spec_MA,'.euler','.Euler');
        bank_pressure_loss_spec_MA=replace(bank_pressure_loss_spec_MA,'.martin','.Martin');
        out=setValue(out,'bank_pressure_loss_spec_MA',bank_pressure_loss_spec_MA);
    end

    bank_heat_coeff_spec_MA=getValue(out,'bank_heat_coeff_spec_MA');
    if~isempty(bank_heat_coeff_spec_MA)
        bank_heat_coeff_spec_MA=replace(bank_heat_coeff_spec_MA,...
        'fluids.interfaces.heat_exchangers.condenser_evaporator_2P_MA_private.bank_heat_coeff_spec',...
        'fluids.interfaces.heat_exchangers.enum.BankHeatCoeffSpec');
        bank_heat_coeff_spec_MA=replace(bank_heat_coeff_spec_MA,'.colburn','.Colburn');
        bank_heat_coeff_spec_MA=replace(bank_heat_coeff_spec_MA,'.martin','.Martin');
        out=setValue(out,'bank_heat_coeff_spec_MA',bank_heat_coeff_spec_MA);
    end

end