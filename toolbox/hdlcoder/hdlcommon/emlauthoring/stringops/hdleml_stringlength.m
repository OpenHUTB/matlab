%#codegen
function y=hdleml_stringlength(outtp_ex,u)

    coder.allowpcode('plain')
    eml_prefer_const(outtp_ex);


    len=uint32(0);


    for ii=1:length(u)
        if(u(ii)~=0)
            len=len+1;
        end
    end

    y=fi(len,numerictype(outtp_ex));
