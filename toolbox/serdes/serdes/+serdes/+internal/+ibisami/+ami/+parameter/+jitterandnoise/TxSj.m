classdef TxSj<serdes.internal.ibisami.ami.parameter.jitterandnoise.JitterCommon

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
...
...
...
...
...

    properties
    end



    methods
        function param=TxSj()
            param.NodeName="Tx_Sj";
            param.Description="Tx Sinusoidal Jitter in UI.";
            param.DirectionRx=false;
        end
    end
end

