classdef Dialog<handle



    properties(GetAccess=public,SetAccess=private)
        WebWindow;
        ViewModel;
        URL;
        port;
    end
    methods
        function obj=Dialog(viewModel,url)
            obj.URL=url;
            obj.ViewModel=viewModel;
            obj.port=matlab.internal.getDebugPort();
            obj.WebWindow=matlab.internal.webwindow(url,obj.port);
            obj.WebWindow.Position(3)=1000;
            obj.WebWindow.show();
        end
        function delete(obj)
            obj.WebWindow.close();
        end
        function url=getURL(obj)
            url=obj.URL;
        end
        function close(obj)
            obj.WebWindow.close();
        end
    end
end
