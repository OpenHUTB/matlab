classdef(Abstract)AbstractProfiler<handle




    methods(Abstract)

        turnOn(obj)

        turnOff(obj)

        resume(obj)

        clear(obj)

        reset(obj)

        info=getInfo(obj)

        status=getStatus(obj)

        configure(obj,options)

        config=getConfig(obj)

        running=isRunning(obj)

        files=getFilesToFilter(obj)
    end
end