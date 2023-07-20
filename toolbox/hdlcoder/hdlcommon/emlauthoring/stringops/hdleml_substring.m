%#codegen
function y=hdleml_substring(outtp_ex,u,idx,varargin)

    coder.allowpcode('plain')
    eml_prefer_const(outtp_ex);

    y1=coder.nullcopy(outtp_ex);


    templen=length(outtp_ex);



    inputlen=fi(length(u),numerictype(idx));

    if nargin==4



        len=varargin{1};
        outlen=fi(templen,numerictype(len));
    else


        len=uint32(length(u));
        outlen=templen;
    end



    for jj=1:outlen
        if(jj<=len)
            if(idx+jj-1<=inputlen)
                y1(jj)=u(idx+jj-1);
            else
                y1(jj)=0;
            end
        else
            y1(jj)=0;
        end
    end

    y=y1;