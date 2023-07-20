function s=issigned(x)



%#codegen



    coder.allowpcode('plain');
    coder.inline('always');



    if isa(x,'logical')
        s=false;
        return;
    end


    coder.internal.assert(isnumeric(x),'fixed:coder:inputMustBeNumeric');
    if isfi(x)
        s=issigned(x);
    elseif isfloat(x)
        s=true;
    elseif isinteger(x)
        if isa(x,'uint8')||isa(x,'uint16')||isa(x,'uint32')||...
            isa(x,'uint64')
            s=false;
        else
            s=true;
        end
    else






        coder.internal.assert(false,'fixed:coder:inputTypeUnsupported',...
        class(x),mfilename);
    end
end
