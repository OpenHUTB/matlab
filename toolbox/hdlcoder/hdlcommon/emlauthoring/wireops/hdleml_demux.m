%#codegen
function varargout=hdleml_demux(u,outLen)



    coder.allowpcode('plain')
    eml_prefer_const(outLen);









    if nargin<2
        outLen=ones(1,length(u));
    end

    j=1;
    for i=1:length(outLen)
        dimLen=outLen(i);
        if dimLen>1

            varargout{i}=hdleml_define_len(u(1),dimLen);
            for k=1:dimLen
                varargout{i}(k)=u(j+k-1);
            end
        else

            varargout{i}=u(j);
        end
        j=j+dimLen;
    end
