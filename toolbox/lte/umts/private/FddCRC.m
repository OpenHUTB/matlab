










































function[out,varargout]=FddCRC(data,direction,PolyId,mask)
    if nargin==3
        mask=0;
    end


    if(isempty(data))
        out=double(fdd('CrcCoder',data,direction,PolyId,mask)).';
        return
    end

    if direction
        out=fdd('CrcCoder',data,direction,PolyId,mask);
    else
        [out,x]=fdd('CrcCoder',data,direction,PolyId,mask);
        varargout{1}=x;
    end

    out=double(out);

    if(size(data,1)==1)
        if(size(out,1)~=1)
            out=out.';
        end
    elseif(size(data,2)==1)
        if(size(out,2)~=1)
            out=out.';
        end
    end
end