classdef Oslc<mls.internal.HttpService










    properties
initialRest
    end

    methods(Static)

        function success=register()
            if~connector.internal.MatlabService.hasRegisteredService('oslc')
                myService=slreq.connector.Oslc.getInstance();
                mls.internal.HttpService.registerService('oslc',myService);
                success=myService.isvalid;




                myService.initialRest=connector.internal.getConfig('enableRestMatlab');
                if~myService.initialRest
                    connector.internal.setConfig('enableRestMatlab',1);
                end
            else
                success=false;
            end
        end

        function success=unregister()
            if connector.internal.MatlabService.hasRegisteredService('oslc')
                myService=slreq.connector.Oslc.getInstance();
                if~myService.initialRest

                    connector.internal.setConfig('enableRestMatlab',0);
                end
                mls.internal.HttpService.deregisterService('oslc');
                success=true;
            else
                success=false;
            end
        end

        function yesno=isRegistered()
            yesno=connector.internal.MatlabService.hasRegisteredService('oslc');
        end

    end

    methods(Static,Access='private')

        function service=getInstance()
            persistent myService;
            if isempty(myService)
                if connector.internal.MatlabService.hasRegisteredService('oslc')

                    myService=connector.internal.MatlabService.getRegisteredService('oslc');
                else

                    myService=slreq.connector.Oslc();
                end
            end
            if myService.isvalid
                service=myService;
            else

                myService=slreq.connector.Oslc();
                service=myService;
            end
        end

        function response=makeErrorResponse(ex)
            response.ContentType='text/html';
            response.Data=['<html><body><font color="red">ERROR:<br/>'...
            ,ex.identifier,':<br/>',ex.message,'</font></body></html>'];
            response.StatusCode=200;
        end

    end

    methods(Access='private')
        function service=Oslc(varargin)
            service.initialRest=connector.internal.getConfig('enableRestMatlab');


        end
    end

    methods

        function doGet(obj,httpRequest,httpResponse)%#ok<INUSL>
            try
                switch httpRequest.Path
                case '/select'

                    oslc.selection(httpRequest.Parameters('id'),httpRequest.Parameters('label'));
                    httpResponse.StatusCode=204;
                case '/clear'

                    oslc.selection('','');
                    httpResponse.StatusCode=204;
                case '/json'

                    if isKey(httpRequest.Parameters,'selection')

                        selectionInfo=urldecode(httpRequest.Parameters('selection'));
                        [ids,label]=strtok(selectionInfo);
                        selectionUpdated=oslc.selection(ids,label(2:end));
                    else
                        selectionUpdated=true;
                    end
                    if selectionUpdated
                        if isKey(httpRequest.Parameters,'local')

                            oslc.config.inBrowser(...
                            httpRequest.Parameters('change'),...
                            httpRequest.Parameters('local'),...
                            httpRequest.Parameters('component'),...
                            httpRequest.Parameters('global'));
                        end
                    else







                    end

                    httpResponse.ContentType='application/json;charset=utf-8';
                    httpResponse.Data=['[{"input":"',httpRequest.Path,'"}]'];
                    httpResponse.StatusCode=200;
                case '/inboundTest'
                    oslc.inboundTest();
                    httpResponse.StatusCode=204;
                case '/show'



                otherwise


                    httpResponse.ContentType='text/html;charset=utf-8';
                    content=slreq.connector.processRequest(httpRequest.Path,httpRequest.Parameters);
                    if isempty(content)

                        httpResponse.Data='';
                        httpResponse.StatusCode=204;
                    else
                        httpResponse.Data=unicode2native(content,'utf-8');
                        httpResponse.StatusCode=200;
                    end

                end
            catch ex
                httpResponse=slreq.connector.Oslc.makeErrorResponse(ex);%#ok<NASGU>
            end
        end

        function doPost(obj,httpRequest,httpResponse)
            doGet(obj,httpRequest,httpResponse);
        end
    end
end

