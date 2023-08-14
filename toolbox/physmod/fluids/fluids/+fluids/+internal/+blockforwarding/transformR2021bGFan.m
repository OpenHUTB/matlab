function out=transformR2021bGFan(in)




    out=in;

    fan_spec=getValue(out,'fan_spec');
    if~isempty(fan_spec)
        if strcmp(fan_spec,'fluids.gas.enum.fan_spec.table1D')||strcmp(fan_spec,'1')
            fan_parameterization='fluids.gas.turbomachinery.enum.FanParameterization.Table1D';
        elseif strcmp(fan_spec,'fluids.gas.enum.fan_spec.table2D_flow_omega')||strcmp(fan_spec,'2')
            fan_parameterization='fluids.gas.turbomachinery.enum.FanParameterization.Table2DPressure';
        elseif strcmp(fan_spec,'fluids.gas.enum.fan_spec.table2D_dp_omega')||strcmp(fan_spec,'3')
            fan_parameterization='fluids.gas.turbomachinery.enum.FanParameterization.Table2DFlowRate';
        elseif strcmp(fan_spec,'fluids.gas.enum.fan_spec.table2D_dp_dpmax_omega')||strcmp(fan_spec,'4')

            out=setNewBlockPath(out,'gas_legacy_lib/Turbomachinery/Fan (G) - Legacy');
            out=setClass(out,'gas_legacy.turbomachinery.fan');
            return
        end
        out=setValue(out,'fan_parameterization',fan_parameterization);
    end

    mech_orientation=getValue(out,'mech_orientation');
    if~isempty(mech_orientation)
        if strcmp(mech_orientation,'simscape.enum.posneg.positive')
            mech_orientation='fluids.gas.turbomachinery.enum.FanMechanicalOrientation.Positive';
        elseif strcmp(mech_orientation,'simscape.enum.posneg.negative')
            mech_orientation='fluids.gas.turbomachinery.enum.FanMechanicalOrientation.Negative';
        end
        out=setValue(out,'mech_orientation',mech_orientation);
    end

end