%#codegen

function data=generic_logger(idx_in,val_in)
    coder.inline('never');
    coder.allowpcode('plain');
    coder.varsize('bytes','val_flat',[1,inf]);
    if nargin==2
        idx=idx_in;

        if idx>1&&~isempty(val_in)
            v1=double(val_in(1));
            localMin=v1;
            localMax=v1;

            for ii=2:numel(val_in)
                v=double(val_in(ii));
                if v>localMax
                    localMax=v;
                elseif v<localMin
                    localMin=v;
                end
            end

            if~buffers('hasItem',idx)
                buffers('initItem',idx,get_buffer_template(val_in));
            end

            val_flat=val_in(:)';
            bytes=tobytes(val_flat);
            buffers('appendBytes',idx,bytes,localMin,localMax);
        end
    elseif nargin==0&&nargout==1
        data=buffers('getBuffers');
    end
end

function bytes=tobytes(val_in)
    coder.varsize('bytes',[1,inf]);
    if isfi(val_in)
        ints=fi2sim(val_in);

        bytes=tobytes(ints(:)');
    elseif islogical(val_in)
        bytes=uint8(val_in);
    elseif isnumeric(val_in)
        bytes=typecast(val_in,'uint8');
    else
        eml_assert(0,'Unsupported type in generic_logger');
    end
end

function S=get_buffer_template(val)
    coder.inline('never');
    coder.extrinsic('tostring');
    coder.varsize('S.Class','S.Dims','S.NumericType','S.Fimath','S.Data',[1,inf]);
    S.Class=class(val);
    S.Dims=size(val);

    S.Varsize=~coder.internal.isConst(size(val));

    if isfi(val)
        S.NumericType=coder.const(tostring(numerictype(val)));
        S.Fimath=coder.const(tostring(fimath(val)));
    else
        S.NumericType='';
        S.Fimath='';
    end

    S.Data=uint8(0);
    S.DataSize=uint32(1);
    S.Min=inf;
    S.Max=-inf;
end

function out=buffers(action,idx,arg,localMin,localMax)
    coder.inline('never');
    persistent pBuffers
    if isempty(pBuffers)
        pBuffers=get_buffer_template(0);

        coder.varsize('pBuffers',[1,inf]);
    end

    switch action
    case 'hasItem'
        out=(idx<=numel(pBuffers))&&(pBuffers(idx).DataSize>1);

    case 'initItem'
        if idx>numel(pBuffers)
            pBuffers=[pBuffers,repmat(pBuffers(1),1,idx-numel(pBuffers))];
        end
        buffer=arg;
        pBuffers(idx)=buffer;

    case 'getBuffers'
        out=pBuffers;
        pBuffers=pBuffers(1);

    case 'appendBytes'
        bytes=arg;

        size=pBuffers(idx).DataSize;
        capacity=numel(pBuffers(idx).Data);
        if size+numel(bytes)>capacity
            newSize=max(capacity*2,size+numel(bytes));
            pBuffers(idx).Data=[pBuffers(idx).Data,zeros(1,newSize-capacity,'uint8')];
        end

        pBuffers(idx).Data(size:size+numel(bytes)-1)=bytes(:);
        pBuffers(idx).DataSize=size+numel(bytes);
        if localMin<pBuffers(idx).Min
            pBuffers(idx).Min=localMin;
        end
        if localMax>pBuffers(idx).Max
            pBuffers(idx).Max=localMax;
        end

    end
end

