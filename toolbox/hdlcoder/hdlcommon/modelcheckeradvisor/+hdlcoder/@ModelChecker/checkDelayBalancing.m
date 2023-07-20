function flag=checkDelayBalancing(this)




    delay_balancing_list={'Simulink and Incisive Cosimulation','Simulink and ModelSim Cosimulation','Simulink and Vivado Simulator Cosimulation','To VCD File',...
    'DataTypeDuplicate','FrameConversion','HDL Minimum Resource FFT','Ground','LMS Filter','ModelReference','NCO','Sine Wave','MagnitudeAngleToComplex'};
    delay_balancing_sources=strjoin(delay_balancing_list,'|');

    [flag,blocks]=this.getMatchingHandleAndMaskedBlocks(delay_balancing_sources,'no-delay-balancing');%#ok<ASGLU>
end
