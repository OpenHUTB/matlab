classdef MatlabService<handle


    properties(Constant)
        This=connector.internal.MatlabService
    end


    properties(Access=private)
        services=containers.Map
    end

    methods(Access=private)
        function obj=MatlabService()
        end

        function lock(obj)
            if~mislocked
                mlock;
            end
        end

        function unlock(obj)

            if obj.services.Count==0
                munlock;
            end
        end
    end


    methods(Static,Sealed=true)
        function registerService(name,service)
            connector.internal.MatlabService.This.lock();
            services=connector.internal.MatlabService.This.services;
            services(name)=service;
        end

        function deregisterService(name)
            connector.internal.MatlabService.This.lock();
            if isvalid(connector.internal.MatlabService.This.services)&&...
                connector.internal.MatlabService.This.services.isKey(name)

                service=connector.internal.MatlabService.This.services(name);
                connector.internal.MatlabService.This.services.remove(name);
                if isvalid(service)
                    delete(service);
                end
            end
            connector.internal.MatlabService.This.unlock();
        end

        function result=hasRegisteredService(name)
            result=connector.internal.MatlabService.This.services.isKey(name);
        end

        function service=getRegisteredService(name)
            if connector.internal.MatlabService.This.services.isKey(name)
                service=connector.internal.MatlabService.This.services(name);
            end
        end


        function[statusCode,contentType,responseHeaders,data]=service(method,fullPath,queryString,requestParameters)
            contentType='';
            responseHeaders={};
            data=zeros(0,1,'uint8');

            parameters=containers.Map;

            for i=1:2:numel(requestParameters)
                parameters(requestParameters{i})=requestParameters{i+1};
            end

            subPathIndex=strfind(fullPath,'/');

            if numel(subPathIndex)>1||numel(fullPath)>1
                if numel(subPathIndex)<2
                    subPathEnd=numel(fullPath);
                    subPath=fullPath(1:subPathEnd);
                else
                    subPathEnd=subPathIndex(2)-1;
                    subPath=fullPath(subPathIndex(1)+1:subPathEnd);
                end

                if connector.internal.MatlabService.hasRegisteredService(subPath)
                    try
                        httpService=connector.internal.MatlabService.getRegisteredService(subPath);

                        request=mls.internal.HttpRequest(method,fullPath(min(end,subPathEnd+1):end),queryString,parameters);
                        response=httpService.service(request);

                        responseHeaders={'Connection','close',...
                        'Accept-Ranges','bytes',...
                        'Content-Length',num2str(numel(response.Data))};
                        contentType=response.ContentType;
                        data=response.Data;
                        statusCode=response.StatusCode;

                    catch e %#ok<NASGU>
                        statusCode=500;
                    end
                else
                    statusCode=404;
                end

            else
                statusCode=404;
            end

        end

    end
end