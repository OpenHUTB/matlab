classdef onExit<handle
    properties(SetAccess='private',GetAccess='public',Transient)
        Task=@nop
        Cancelled=false
    end

    methods
        function h=onExit(functionHandle)
            h.Task=functionHandle;
        end

        function cancel(h)
            h.Cancelled=true;
            h.Task=@nop;
        end

        function delete(h)
            if~h.Cancelled
                h.Task();
            end
        end
    end
end

function nop
end