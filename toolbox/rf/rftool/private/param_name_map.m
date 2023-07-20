function out_str=param_name_map(in_str,flag)




    parameter_name_table={...
    'Z0','Z0 (ohms)';
    'PV','Phase Velocity (m/s)';
    'Loss','Loss (dB/m)';
    'LineLength','Line Length (m)';
    'Radius','Radius (m)';
    'Separation','Separation (m)';
    'MuR','MuR';
    'EpsilonR','EpsilonR';
    'SigmaCond','Conductivity of conductor (S/m)';
    'Width','Width (m)';
    'Height','Height (m)';
    'Thickness','Thickness (m)';
    'LossTangent','Loss tangent of dielectric';
    'InnerRadius','Inner Radius (m)';
    'OuterRadius','Outer Radius (m)';
    'R','R (ohms)';
    'L','L (H)';
    'C','C (F)';
    'StubMode','Stub Mode';
    'Termination','Termination';
    'File','File Name';
    'IntpType','Interpolation';
    'ConductorWidth','Conductor Width';
    'SlotWidth','Slot Width';
    'Freq','Freq (Hz)';
    'NetworkData','Network Data';
    'NoiseData','Noise Data';
    'NonlinearData','Nonlinear Data';
    'MixerType','Mixer Type';
    'FLO','LO Frequency (Hz)';
    'FreqOffset','Phase Noise Frequency Offset (Hz)';
    'PhaseNoiseLevel','Phase Noise Level (dBc/Hz)';
    'TimeDelay','Time Delay'};
    if flag==1
        idx1=1;
        idx2=2;
    else
        idx1=2;
        idx2=1;
    end
    index=strcmp(in_str,parameter_name_table(:,idx1));
    out_str=parameter_name_table(index,idx2);
end