classdef RxUniformNoise<serdes.internal.ibisami.ami.parameter.jitterandnoise.JitterCommon

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
...



    methods
        function param=RxUniformNoise()
            param.NodeName="Rx_UniformNoise";
            param.Description="Rx uniform amplitude noise at sampling latch in volts.";
            param.Type=serdes.internal.ibisami.ami.type.Float();
            param.AllowedTypes="Float";
            param.DirectionTx=false;
            param.EarliestRequiredVersion=7.0;
        end
    end
end

