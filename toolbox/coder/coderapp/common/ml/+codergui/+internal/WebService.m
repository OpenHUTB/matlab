

classdef(Abstract)WebService<handle


    methods(Abstract)
        start(this,client)

        shutdown(this)
    end

    methods(Static)
        function reply(client,request,channel,varargin)
            if isa(client,'codergui.ReportViewer')
                client=client.Client;
            end
            response=cell2struct(varargin(2:2:numel(varargin)),varargin(1:2:numel(varargin)),2);
            response.requestId=request.requestId;
            response.returnCode=0;
            client.publish(channel,response,true);
        end

        function fail(client,request,channel,err)
            if isa(client,'codergui.ReportViewer')
                client=client.Client;
            end
            if isa(err,'MException')
                err=err.message;
            end
            response.requestId=request.requestId;
            response.returnCode=1;
            response.message=err;
            client.publish(channel,response,true);
        end
    end
end