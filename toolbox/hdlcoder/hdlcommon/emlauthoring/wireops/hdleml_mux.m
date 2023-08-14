%#codegen
function y=hdleml_mux(outEx,varargin)


    coder.allowpcode('plain')
    eml_prefer_const(outEx);

    y=hdleml_define(outEx);



    j=1;
    for i=1:(nargin-1)
        dimLen=length(varargin{i});
        if dimLen>1

            for k=1:dimLen
                y(j+k-1)=varargin{i}(k);
            end
        else

            y(j)=varargin{i};
        end
        j=j+dimLen;
    end
