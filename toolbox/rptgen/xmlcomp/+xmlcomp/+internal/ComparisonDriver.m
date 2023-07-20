


classdef ComparisonDriver<handle


    properties(Access=private)
JComparisonDriver
FilePath1
FilePath2
Parameters
        PollingInterval=0.01;
    end


    methods(Access=public)

        function obj=ComparisonDriver(filePath1,filePath2,parameters)
            obj.FilePath1=filePath1;
            obj.FilePath2=filePath2;
            obj.Parameters=parameters;
            obj.runComparison();
        end

        function comparison=getComparison(obj)
            if~isempty(obj.JComparisonDriver)
                comparison=obj.JComparisonDriver.getDTClientPlugin();
            else
                comparison=[];
            end
        end

        function delete(obj)
            if~isempty(obj.JComparisonDriver)
                import com.mathworks.comparisons.matlab.MATLABAPIUtils;
                import comparisons.internal.util.Futures;
                Futures.awaitAndGet(...
                MATLABAPIUtils.disposeAsync(obj.JComparisonDriver)...
                );
            end
        end

    end

    methods(Access=private)

        function runComparison(obj)
            import com.mathworks.toolbox.rptgenxmlcomp.util.CompareAndReturnWaiter;
            import comparisons.internal.util.process;

            waiter=CompareAndReturnWaiter(obj.FilePath1,obj.FilePath2,obj.Parameters);
            waiter.startComparison();

            obj.JComparisonDriver=process(@()obj.compareAndWait(waiter));
        end

        function comparisonResult=compareAndWait(obj,waiter)



            while~waiter.isFinished()
                pause(obj.PollingInterval);
            end
            comparisonResult=waiter.getComparisonResult();
        end

    end

end

