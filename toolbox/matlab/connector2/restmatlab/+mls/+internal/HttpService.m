classdef HttpService<handle


    properties(SetAccess=private)
        Name;
    end

    methods
        function service=HttpService()
        end

        function httpResponse=service(obj,httpRequest)
            httpResponse=mls.internal.HttpResponse;
            if strcmpi(httpRequest.Method,'get')
                obj.doGet(httpRequest,httpResponse);
            elseif strcmpi(httpRequest.Method,'post')
                obj.doPost(httpRequest,httpResponse);
            end
        end

        function doGet(obj,~,~)%#ok<MANU>
        end

        function doPost(obj,~,~)%#ok<MANU>
        end
    end

    methods(Static,Sealed=true)
        function registerService(name,service)
            connector.internal.MatlabService.registerService(name,service);
        end

        function deregisterService(name)
            connector.internal.MatlabService.deregisterService(name);
        end

        function result=hasRegisteredService(name)
            result=connector.internal.MatlabService.hasRegisteredService(name);
        end

        function service=getRegisteredService(name)
            service=connector.internal.MatlabService.getRegisteredService(name);
        end
    end
end