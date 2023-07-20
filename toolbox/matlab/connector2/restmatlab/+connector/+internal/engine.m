
function response=engine(requestJSON)


    response.results='';
    response.error='';

    try
        request=mls.internal.fromJSON(requestJSON);
        arguments=request.arguments;
        if~isempty(arguments)&&~iscell(arguments)
            if size(arguments,1)==1
                arguments={arguments};
            else
                arguments=num2cell(arguments);
            end
        end

        if request.nargout==0
            if isempty(arguments)
                feval(request.function);
            else
                feval(request.function,arguments{:});
            end
        else
            results=cell(request.nargout,1);
            if isempty(arguments)
                [results{:}]=feval(request.function);
            else
                [results{:}]=feval(request.function,arguments{:});
            end
            response.results=results;
        end
    catch e
        response.error=e.message;
    end

    response=mls.internal.toJSON(response);
