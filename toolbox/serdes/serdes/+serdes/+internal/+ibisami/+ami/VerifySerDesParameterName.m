function ok=VerifySerDesParameterName(varargin)








    if nargin<1
        paramName='<unnamed>';
    else
        paramName=varargin{1};
    end
    rp=serdes.internal.ibisami.ami.RepairSerDesParameterName(paramName);
    ok=serdes.internal.ibisami.ami.VerifySerDesNodeName(rp,false);
    if~ok&&(nargin<2||varargin{2})
        if~isempty(paramName)&&strtrim(paramName)~=""
            n=paramName;
        else
            n="<unnamed>";
        end
        error(message('serdes:ibis:InvalidSerDesParameter',n))
    end
end

