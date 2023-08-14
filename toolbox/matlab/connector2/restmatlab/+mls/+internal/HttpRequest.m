classdef HttpRequest<handle


    properties(SetAccess=private)
        Method;
        Path;
        QueryString;
        Parameters;
    end

    methods
        function request=HttpRequest(method,path,queryString,parameters)
            request.Method=method;
            request.Path=path;
            request.QueryString=queryString;
            request.Parameters=parameters;
        end
    end
end