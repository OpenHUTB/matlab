classdef InitReturnsImpulse<serdes.internal.ibisami.ami.parameter.GeneralReservedParameter

...
...
...
...
...
...
...
...



    methods
        function param=InitReturnsImpulse()
            param.NodeName="Init_Returns_Impulse";
            param.Usage=serdes.internal.ibisami.ami.usage.Info();
            param.Type=serdes.internal.ibisami.ami.type.Boolean();
            param.Format=serdes.internal.ibisami.ami.format.Value({true});
            param.Description="When True, this model supports AMI_Init (statistical) simulation.";
        end
    end
end

