classdef Pam4UpperThreshold<serdes.internal.ibisami.ami.parameter.modulation.Pam4Threshold

...
...
...
...
...
...
...
...
...
...
...



    methods
        function param=Pam4UpperThreshold()
            param.NodeName="PAM4_UpperThreshold";
            param.Description="Upper eye voltage threshold for waveform and eye processing.";
            param.Format=serdes.internal.ibisami.ami.format.Value(0.333);
        end
    end
end

