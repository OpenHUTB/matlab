classdef IPCTypes<uint8










    enumeration
        SharedMemory(1)
        Pipes(2)
        Semaphores(3)
        Sockets(4)
        UNSPECIFIED(0)
    end

    methods
        function out=toNum(obj)
            out=double(obj);
        end
    end

end