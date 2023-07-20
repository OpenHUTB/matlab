function str=disableMultirateForSubsystem(subsystem)



    set_param(subsystem,'AutoFrameSizeCalculation','off');
    str=getString(message('dataflow:Multirate:MultirateDisabled',subsystem));
end
