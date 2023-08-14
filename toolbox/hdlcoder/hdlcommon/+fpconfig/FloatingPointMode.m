


classdef FloatingPointMode<hgsetget&fpconfig.DeepCopiable&fpconfig.ReadableMScriptsSerializable
    methods(Abstract=true)
        latency=resolveLatencyFromIPSettings(obj,ips)
    end
end