function y=ceillog2(x)








    switch class(x)
    case 'double'
        y=ceil(log2(abs(x)));
    case{'uint8','int8','uint16','int16','uint32','int32'}
        y=ceil(log2(abs(double(x))));
    case{'uint64','int64'}
        tmpx=fi(x,0,64,0);
        y=ficeillog2(tmpx);
    case 'embedded.fi'
        y=ficeillog2(x);
    end

    function y=ficeillog2(x)
        b=bin(x);
        p=find(b=='1');
        if isempty(p)
            y=-inf;
        elseif numel(p)==1
            y=numel(b)-p(1);
        else
            y=numel(b)-p(1)+1;
        end
        T=numerictype(x);
        y=y-T.FractionLength;

