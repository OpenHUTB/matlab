classdef FevalService<mls.internal.HttpService


    methods(Static)
        function service=init(enabled)
            persistent this;

            if enabled
                mlock;
                if isempty(this)
                    this=mls.internal.FevalService();
                    this.register();
                end
            else
                if~isempty(this)
                    this.deregister();
                    this=[];
                end
                munlock;
            end

            service=this;
        end
    end

    methods
        function service=FevalService(varargin)
        end

        function register(obj)
            mls.internal.HttpService.registerService('feval',obj);
        end

        function deregister(~)
            mls.internal.HttpService.deregisterService('feval');
        end

        function doGet(obj,httpRequest,httpResponse)
            pathParts=regexp(httpRequest.Path,'/','split');

            if numel(pathParts)==2
                arguments='';
                if httpRequest.Parameters.isKey('arguments')
                    arguments=char(connector.internal.urldecode(httpRequest.Parameters('arguments')));
                end
                outputs=0;
                if httpRequest.Parameters.isKey('nargout')
                    outputs=str2double(char(connector.internal.urldecode(httpRequest.Parameters('nargout'))));
                end

                contenttype='';
                if httpRequest.Parameters.isKey('contenttype')
                    contenttype=char(connector.internal.urldecode(httpRequest.Parameters('contenttype')));
                end

                results=connector.internal.feval(pathParts{2},arguments,outputs,contenttype);

                if outputs>0
                    if(isempty(contenttype))
                        httpResponse.ContentType='application/json;charset=utf-8';
                        httpResponse.Data=unicode2native(results,'utf-8');
                    else
                        httpResponse.ContentType=contenttype;
                        httpResponse.Data=unicode2native(char(results),'utf-8');
                    end
                else
                    httpResponse.ContentType='text/html';
                    httpResponse.StatusCode=204;
                end
            else
                httpResponse.StatusCode=404;
            end
        end

        function doPost(obj,httpRequest,httpResponse)
            doGet(obj,httpRequest,httpResponse);
        end
    end
end
