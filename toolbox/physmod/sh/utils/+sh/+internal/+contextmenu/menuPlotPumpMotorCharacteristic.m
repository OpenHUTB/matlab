function schema=menuPlotPumpMotorCharacteristic(callbackInfo)
    schema=sl_action_schema;
    schema.label='Plot Characteristic';
    schema.tag='sh:PlotPumpMotorCharacteristic';
    schema.state='Hidden';
    schema.callback=@lPlotPumpMotorCharacteristic;
    schema.autoDisableWhen='Busy';
    componentPath=callbackInfo.getSelection.ComponentPath;
    if sh.internal.mask.isComponentFixedDisplacementPump(componentPath)||...
        sh.internal.mask.isComponentFixedDisplacementMotor(componentPath)
        schema.state='Enable';
    end
end

function lPlotPumpMotorCharacteristic(callbackInfo)
    sh.internal.mask.plotPumpMotorCharacteristic(callbackInfo.getSelection.Handle);
end
