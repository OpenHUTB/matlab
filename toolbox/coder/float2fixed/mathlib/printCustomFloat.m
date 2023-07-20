










function str=printCustomFloat(x,title)
    assert(numel(x)==1,'Only support scalar input.');

    if~isa(x,'CustomFloat')
        x=CustomFloat(x);
    end

    bstr=[bin(x.Sign),'|',bin(x.Exponent),'|',bin(x.Mantissa)];
    if(x.WordLength<=32)&&(x.MantissaLength<=23)
        num=single(x);
    else
        num=double(x);
    end
    value=storedInteger(bitconcat(x.Sign,x.Exponent,x.Mantissa));

    if(nargout==1)
        if(nargin==1)
            str=sprintf('\t %f    %d    %s',num,value,bstr);
        elseif(nargin==2)
            str=sprintf(['\t ',title,': %f    %d    %s'],num,value,bstr);
        end
    elseif(nargout==0)
        if(nargin==1)
            fprintf('\t %f    %d    %s \n',num,value,bstr);
        elseif(nargin==2)
            fprintf(['\t ',title,': %f    %d    %s \n'],num,value,bstr);
        end
    end
end