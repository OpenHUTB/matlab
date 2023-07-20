function out=transformR2021aTLCentrifugalPump(in)




    out=in;

    pump_parameterization=getValue(out,'pump_parameterization');
    if~isempty(pump_parameterization)
        if strcmp(pump_parameterization,'1')
            pump_parameterization='fluids.thermal_liquid.pumps_motors.enum.CentrifugalPumpParameterization.Table1D';
        elseif strcmp(pump_parameterization,'2')
            pump_parameterization='fluids.thermal_liquid.pumps_motors.enum.CentrifugalPumpParameterization.Table2D';
        end
        out=setValue(out,'pump_parameterization',pump_parameterization);
    end

end