classdef IgnoreBits<serdes.internal.ibisami.ami.parameter.GeneralReservedParameter

...
...
...
...
...
...
...
...



    methods
        function param=IgnoreBits(varargin)
            param.NodeName="Ignore_Bits";
            param.Usage=serdes.internal.ibisami.ami.usage.Info();
            param.Type=serdes.internal.ibisami.ami.type.Integer();
            if nargin>0
                param.Format=serdes.internal.ibisami.ami.format.Value(varargin{1});
            else
                param.Format=serdes.internal.ibisami.ami.format.Value({0});
            end
            param.Description="The number of bits the model parameters can take to settle.";
        end
    end
end

