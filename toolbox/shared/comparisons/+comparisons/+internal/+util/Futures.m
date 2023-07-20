classdef Futures<handle




    properties(Constant,Access=private)
        PollingInterval=0.01;
    end

    methods(Static,Access=public)

        function result=awaitAndGet(jFuture)
            try
                while~jFuture.isDone()
                    pause(comparisons.internal.util.Futures.PollingInterval);
                end
                result=jFuture.get();
            catch exception
                import comparisons.internal.util.APIUtils;
                APIUtils.handleExceptionCallStack(exception);
            end
        end

    end

end
