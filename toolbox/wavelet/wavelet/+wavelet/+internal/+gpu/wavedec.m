function[coeffVals,sizeMat]=wavedec(x,n,Lo_D,Hi_D)%#codegen




    coder.allowpcode('plain');


    coder.gpu.internal.kernelfunImpl(false);


    XISROW=coder.internal.isConst(isrow(x))&&isrow(x);
    XISCOL=coder.internal.isConst(iscolumn(x))&&iscolumn(x);
    VERTCAT=XISCOL&&~XISROW;


    cell_xv=coder.nullcopy(cell(1,n+1));
    cell_d=coder.nullcopy(cell(1,n));
    cell_xv{1}=x(:).';


    if VERTCAT
        sizeMat=coder.nullcopy(zeros(n+2,1,underlyingType(x)));
    else
        sizeMat=coder.nullcopy(zeros(1,n+2,underlyingType(x)));
    end


    if~coder.internal.isConst(n)
        coder.varsize('cell_xv{:}');
    end
    coeffLen=zeros(1,1,underlyingType(x));
    sizeMat(n+2)=numel(x(:));


    for k=1:n
        [cell_xv{k+1},cell_d{k}]=dwt(cell_xv{k},Lo_D,Hi_D);
        sizeMat(n-k+2)=numel(cell_d{k}(:));
        coeffLen=coeffLen+sizeMat(n-k+2);
    end


    sizeMat(1)=numel(cell_xv{n+1}(:));
    if VERTCAT
        coeffVals=coder.nullcopy(zeros(coeffLen+sizeMat(1),1,'like',x));
    else
        coeffVals=coder.nullcopy(zeros(1,coeffLen+sizeMat(1),'like',x));
    end
    startVal=length(coeffVals)*ones(1,1,underlyingType(x));


    for k=1:n
        endVal=startVal;
        startVal=startVal-sizeMat(end-k);

        if VERTCAT
            coeffVals(startVal+1:endVal)=cell_d{k}(:);
        else
            coeffVals(startVal+1:endVal)=cell_d{k}(:).';
        end
        if k==n
            if VERTCAT
                coeffVals(1:sizeMat(1))=cell_xv{n+1}(:);
            else
                coeffVals(1:sizeMat(1))=cell_xv{n+1}(:).';
            end
        end
    end
end