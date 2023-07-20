classdef LogSink<handle&matlab.mixin.Heterogeneous
    methods(Access={?coderapp.internal.log.Logger,?coderapp.internal.log.LogSink})
        function handleMessage(this,msg)%#ok<*INUSD,*MANU>
        end

        function exitScope(this,msg)
        end
    end
end