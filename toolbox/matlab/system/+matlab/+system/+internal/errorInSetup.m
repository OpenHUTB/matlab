function errorInSetup(msgID,msg)
%#codegen

    coder.allowpcode('plain');




    if isInMATLABCoder
        eml_assert(false,msg);
    else
        error(msgID,msg);
    end
end

function flag=isInMATLABCoder

    if~isempty(coder.target)
        flag=true;
    else
        flag=false;
    end
end
