function varargout=batchedMatrixMultiplyFull(...
    TRANSA,...
    TRANSB,...
    alpha,...
    beta,...
    varargin)

%#codegen
    coder.allowpcode('plain');



    if(nargin-4)<3
        return
    end

    coder.internal.errorIf(~(0==mod(nargin-4,3)),'gpucoder:common:BatchedBlasNumArgsMod',4,3);
    batchCount=(nargin-4)/3;

    A1=varargin{1};
    B1=varargin{batchCount+1};
    C1=varargin{(2*batchCount)+1};

    for i=1:(nargin-4)
        coder.internal.errorIf(~(strcmp(class(A1),class(varargin{i}))),'gpucoder:common:BatchedBlasDataTypeMismatch','varargin{1}',['varargin{',num2str(i),'}']);
        coder.internal.errorIf(~ismatrix(varargin{i}),'gpucoder:common:BatchedBlasNonMatrix',i,ndims(varargin{i}));

        coder.internal.errorIf(size(varargin{i},1)==0||size(varargin{i},2)==0,'gpucoder:common:BatchedBlasMatrixWithAZeroDim');


        coder.internal.errorIf(~coder.internal.isConst(size(varargin{i})),'gpucoder:common:BatchedBlasVarDimsUnsupported');
    end
    coder.internal.errorIf(~(strcmp(class(A1),class(alpha))),'gpucoder:common:BatchedBlasDataTypeMismatch','varargin{1}','alpha');
    coder.internal.errorIf(~(strcmp(class(A1),class(beta))),'gpucoder:common:BatchedBlasDataTypeMismatch','varargin{1}','beta');

    coder.internal.errorIf(~(('N'==TRANSA)||('T'==TRANSA)||('C'==TRANSA)),'gpucoder:common:BatchedBlasTransposeArg');
    coder.internal.errorIf(~(('N'==TRANSB)||('T'==TRANSB)||('C'==TRANSB)),'gpucoder:common:BatchedBlasTransposeArg');
    NOTA=('N'==TRANSA);
    NOTB=('N'==TRANSB);
    CONJA=('C'==TRANSA);
    CONJB=('C'==TRANSB);




    a=size(A1,1);
    b=size(A1,2);
    c=size(B1,1);
    d=size(B1,2);
    e=size(C1,1);
    f=size(C1,2);



    for i=1:batchCount

        coder.internal.errorIf(~(a==size(varargin{i},1)),'gpucoder:common:BatchedBlasNonUniformRowDims',...
        i,'A',a,size(varargin{i},1));
        coder.internal.errorIf(~(b==size(varargin{i},2)),'gpucoder:common:BatchedBlasNonUniformColDims',...
        i,'A',b,size(varargin{i},2));


        i_b=batchCount+i;
        coder.internal.errorIf(~(c==size(varargin{i_b},1)),'gpucoder:common:BatchedBlasNonUniformRowDims',...
        i,'B',c,size(varargin{i_b},1));
        coder.internal.errorIf(~(d==size(varargin{i_b},2)),'gpucoder:common:BatchedBlasNonUniformColDims',...
        i,'B',d,size(varargin{i_b},2));


        i_c=(2*batchCount)+i;
        coder.internal.errorIf(~(e==size(varargin{i_c},1)),'gpucoder:common:BatchedBlasNonUniformRowDims',...
        i,'C',e,size(varargin{i_c},1));
        coder.internal.errorIf(~(f==size(varargin{i_c},2)),'gpucoder:common:BatchedBlasNonUniformColDims',...
        i,'C',f,size(varargin{i_c},2));
    end


    if NOTA

        coder.internal.errorIf(a~=e,'gpucoder:common:BatchedBlasMatrixDimMismatchRow',...
        'C','A',a,e);
        k=size(A1,2);
    else

        coder.internal.errorIf(b~=e,'gpucoder:common:BatchedBlasMatrixDimMismatchCol',...
        'C','A',b,e);
        k=size(A1,1);
    end

    if NOTB

        coder.internal.errorIf(k~=c,'gpucoder:common:BatchedBlasMatrixDimMismatchRow',...
        'B','A',k,c);
        coder.internal.errorIf(d~=f,'gpucoder:common:BatchedBlasMatrixDimMismatchCol',...
        'C','B',d,f);
    else

        coder.internal.errorIf(k~=d,'gpucoder:common:BatchedBlasMatrixDimMismatchCol',...
        'B','A',k,d);
        coder.internal.errorIf(c~=f,'gpucoder:common:BatchedBlasMatrixDimMismatchRow',...
        'C','B',c,f);
    end
    lda=size(A1,1);
    ldb=size(B1,1);
    ldc=size(C1,1);

    if coder.target('MATLAB')
        if NOTA
            opA=@(submat)submat;
        elseif CONJA
            opA=@(submat)submat';
        else
            opA=@(submat)submat.';
        end
        if NOTB
            opB=@(submat)submat;
        elseif CONJB
            opB=@(submat)submat';
        else
            opB=@(submat)submat.';
        end
        for i=1:batchCount
            varargin{(2*batchCount)+i}=alpha.*opA(varargin{i})*opB(varargin{batchCount+i})+...
            beta.*varargin{(2*batchCount)+i};
        end
        varargout=varargin(((2*batchCount)+1):end);
    else
        varargout=coder.internal.blas.xgemmBatched(...
        TRANSA,...
        TRANSB,...
        e,f,k,...
        alpha,...
        lda,...
        ldb,...
        beta,...
        ldc,...
        batchCount,...
        varargin);
    end


end
