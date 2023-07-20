classdef RxGaussianNoise<serdes.internal.ibisami.ami.parameter.jitterandnoise.RxNoise




    methods
        function param=RxGaussianNoise()
            param.NodeName="Rx_GaussianNoise";
            param.EarliestRequiredVersion=7.0;
        end
    end
end

