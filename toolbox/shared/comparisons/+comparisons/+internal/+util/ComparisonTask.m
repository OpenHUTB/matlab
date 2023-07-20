classdef ComparisonTask<handle









    properties(Constant,Access=private)
        PollingInterval=0.01;
    end

    properties(Access=private)
        ComparisonDriver;
        Done;
    end

    properties(GetAccess=public)
        Cancelled;
    end

    methods(Access=public)

        function obj=ComparisonTask(driver)
            obj.ComparisonDriver=driver;
            obj.Cancelled=false;
            obj.Done=false;
        end

        function invokeAndWait(this)




            this.startComparison();
            this.await(this.ComparisonDriver.getResult());
            this.report();
        end

    end

    methods(Access=private)

        function startComparison(this)
            this.ComparisonDriver.startComparison();
        end

        function await(this,future)
            cleanup=onCleanup(@()this.cancel(future));
            while~future.isDone()
                pause(this.PollingInterval);
            end
            this.Done=true;
        end

        function report(this)
            this.ComparisonDriver.getResult().get();
        end

        function cancel(this,task)
            if~this.Done
                this.Cancelled=true;
                task.cancel(true);
            end
        end

    end

end