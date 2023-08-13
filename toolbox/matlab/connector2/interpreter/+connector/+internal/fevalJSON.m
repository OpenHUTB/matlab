function result=fevalJSON(functionName,arguments,numberOfOutputs,varargin)

    if nargin>3
        hotlinks=varargin{1};

        oldHotlinks=feature('HotLinks');
        feature('HotLinks',hotlinks);
        cleanup=onCleanup(@()feature('HotLinks',oldHotlinks));
    end

    result=struct('results','[]','error',false,'faultMessage','');
    try
        response=connector.internal.fevalMatlab(functionName,arguments,numberOfOutputs);
    catch ex
        response='';
        result.error=true;
        if isa(ex,'MException')
            result.faultMessage=ex.message;
        end
    end

    if numberOfOutputs~=0&&~isempty(response)
        result.results=mls.internal.toJSON(response);
    end

end
