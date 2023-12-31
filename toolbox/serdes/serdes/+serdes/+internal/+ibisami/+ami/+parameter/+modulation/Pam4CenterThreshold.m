classdef Pam4CenterThreshold<serdes.internal.ibisami.ami.parameter.modulation.Pam4Threshold

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
        function param=Pam4CenterThreshold()
            param.NodeName="PAM4_CenterThreshold";
            param.Description="Center eye voltage threshold for waveform and eye processing.";
            param.Format=serdes.internal.ibisami.ami.format.Value(0.0);
        end
    end
end

