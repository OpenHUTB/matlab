


















function y=fillFftComplexConjugateMirror(x,ySize,dims)%#codegen
    coder.inline('always');
    coder.allowpcode('plain');


    rank=numel(dims);

    if rank==1
        y=fillFftComplexConjugateMirror1d(x,ySize,dims);
    elseif rank==2
        y=fillFftComplexConjugateMirror2d(x,ySize);
    else
        y=fillFftComplexConjugateMirror3d(x,ySize);
    end

end

function y=fillFftComplexConjugateMirror1d(x,ySize,dim)
    coder.inline('always');
    coder.allowpcode('plain');

    ONE=coder.internal.indexInt(1);
    TWO=coder.internal.indexInt(2);
    y=x;
    N=coder.internal.indexInt(ySize(dim));

    midpoint=(N+1)/2;
    numDims=numel(ySize);


    if isvector(x)
        for i=TWO:midpoint
            y(N-i+TWO)=conj(y(i));
        end
    elseif numDims==2

        if dim==1
            for i=ONE:size(y,2)
                for j=TWO:midpoint
                    y(N-j+TWO,i)=conj(y(j,i));
                end
            end
        else
            for i=TWO:midpoint
                for j=ONE:size(y,1)
                    y(j,N-i+TWO)=conj(y(j,i));
                end
            end
        end
    else
        if dim==1
            nbatches=coder.internal.indexInt(numel(y)/N);
            for i=0:nbatches-1
                for j=TWO:midpoint
                    offset=i*N;
                    y(N-j+TWO+offset)=conj(y(j+offset));
                end
            end
        else
            n=ndims(y);
            source=cell(1,n);
            mirror=cell(1,n);
            for i=1:n
                if i~=dim
                    source{i}=ONE:ySize(i);
                    mirror{i}=ONE:ySize(i);
                end
            end

            for i=TWO:midpoint
                source{dim}=i;
                mirror{dim}=N-i+TWO;
                y(mirror{:})=conj(y(source{:}));
            end
        end
    end
end

function y=fillFftComplexConjugateMirror2d(x,ySize)
    coder.inline('always');
    coder.allowpcode('plain');

    ONE=coder.internal.indexInt(1);
    TWO=coder.internal.indexInt(2);
    y=x;
    rows=coder.internal.indexInt(ySize(ONE));
    cols=coder.internal.indexInt(ySize(TWO));
    midpoint=coder.internal.indexInt((rows+1)/TWO);

    coder.gpu.internal.kernelImpl(false);
    for i=1:cols
        coder.gpu.internal.kernelImpl(false);
        for j=midpoint+ONE:rows
            col=mod(cols-i+ONE,cols)+ONE;
            row=rows-j+TWO;
            y(j,i)=conj(y(row,col));
        end
    end
end

function y=fillFftComplexConjugateMirror3d(x,ySize)
    coder.inline('always');
    coder.allowpcode('plain');

    y=x;
    ONE=coder.internal.indexInt(1);
    TWO=coder.internal.indexInt(2);
    THREE=coder.internal.indexInt(3);
    rows=coder.internal.indexInt(ySize(ONE));
    cols=coder.internal.indexInt(ySize(TWO));
    depth=coder.internal.indexInt(ySize(THREE));
    midpoint=coder.internal.indexInt((rows+1)/TWO);
    numDims=numel(ySize);

    mirrorIdx=cell(1,numDims);
    sourceIdx=cell(1,numDims);
    if numDims>3
        for i=4:numDims
            mirrorIdx{i}=ONE:ySize(i);
            sourceIdx{i}=ONE:ySize(i);
        end
    end

    coder.gpu.internal.kernelImpl(false);
    for i=ONE:depth
        coder.gpu.internal.kernelImpl(false);
        for j=ONE:cols
            coder.gpu.internal.kernelImpl(false);
            for k=midpoint+ONE:rows
                z_idx=mod(depth-i+ONE,depth)+ONE;
                sourceIdx{3}=z_idx;
                mirrorIdx{3}=i;
                col=mod(cols-j+ONE,cols)+ONE;
                sourceIdx{2}=col;
                mirrorIdx{2}=j;
                row=rows-k+TWO;
                sourceIdx{1}=row;
                mirrorIdx{1}=k;
                y(mirrorIdx{:})=conj(y(sourceIdx{:}));
            end
        end
    end
end
