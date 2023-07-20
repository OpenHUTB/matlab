classdef(CaseInsensitiveProperties=true)Callback<matlab.mixin.Heterogeneous&matlab.mixin.Copyable

    properties(SetAccess=public)

        CallbackHandle=[];





        PreCallbackHandle=[];
        PostCallbackHandle=[];
    end

    properties(Hidden=true)

        ReportCallbackHandle=@ModelAdvisor.Report.DefaultReportCallback;
    end

    methods

        function set.CallbackHandle(obj,value)
mlock
            obj.CallbackHandle=value;
        end











        function set.PreCallbackHandle(obj,value)
            obj.PreCallbackHandle=value;
        end

        function set.PostCallbackHandle(obj,value)
            obj.PostCallbackHandle=value;
        end

        function value=get.CallbackHandle(obj)
            value=obj.CallbackHandle;
        end









        function value=get.PreCallbackHandle(obj)
            value=obj.PreCallbackHandle;
        end

        function value=get.PostCallbackHandle(obj)
            value=obj.PostCallbackHandle;
        end

    end
end
