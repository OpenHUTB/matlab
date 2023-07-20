%#codegen
function C=cpu_mm_kernel(func,A,B,varargin)



    coder.allowpcode('plain');
    coder.internal.assert((nargin==3)||(nargin==4),'gpucoder:common:MMKernelWrongNumArgs','gpucoder.matrixMatrixKernel',nargin);
    if(numel(varargin)==0)
        coder.internal.assert(size(A,2)==size(B,1),'gpucoder:common:MMKernelIncompatDims');
        C=cpu_mm_kernel_nn(func,A,B);
        return
    end

    switch lower(varargin{1})
    case 'nn'
        coder.internal.assert(size(A,2)==size(B,1),'gpucoder:common:MMKernelIncompatDims');
        C=cpu_mm_kernel_nn(func,A,B);
    case 'nt'
        coder.internal.assert(size(A,2)==size(B,2),'gpucoder:common:MMKernelIncompatDims');
        C=cpu_mm_kernel_nt(func,A,B);
    case 'tn'
        coder.internal.assert(size(A,1)==size(B,1),'gpucoder:common:MMKernelIncompatDims');
        C=cpu_mm_kernel_tn(func,A,B);
    case 'tt'
        coder.internal.assert(size(A,1)==size(B,2),'gpucoder:common:MMKernelIncompatDims');
        C=cpu_mm_kernel_tt(func,A,B);
    otherwise
        error(message('gpucoder:common:MMKernelInvalidTrans','''nn'', ''nt'', ''tn'', or ''tt'''));
    end

end

function C=cpu_mm_kernel_nn(func,A,B)
    C=zeros(size(A,1),size(B,2),'like',A);
    parfor j=1:size(B,2)
        row_result=zeros(size(A,1),1,'like',A);
        for i=1:size(A,1)
            row_result(i)=sum(func(A(i,:),B(:,j)'));%#ok<PFBNS>
        end
        C(:,j)=row_result;
    end
end

function C=cpu_mm_kernel_nt(func,A,B)
    C=zeros(size(A,1),size(B,1),'like',A);
    parfor j=1:size(B,1)
        row_result=zeros(size(A,1),1,'like',A);
        for i=1:size(A,1)
            row_result(i)=sum(func(A(i,:),B(j,:)));%#ok<PFBNS>
        end
        C(:,j)=row_result;
    end
end

function C=cpu_mm_kernel_tn(func,A,B)
    C=zeros(size(A,2),size(B,2),'like',A);
    parfor j=1:size(B,2)
        row_result=zeros(size(A,2),1,'like',A);
        for i=1:size(A,2)
            row_result(i)=sum(func(A(:,i),B(:,j)));%#ok<PFBNS>
        end
        C(:,j)=row_result;
    end
end

function C=cpu_mm_kernel_tt(func,A,B)
    C=zeros(size(A,2),size(B,1),'like',A);
    parfor j=1:size(B,1)
        row_result=zeros(size(A,2),1,'like',A);
        for i=1:size(A,2)
            row_result(i)=sum(func(A(:,i)',B(j,:)));%#ok<PFBNS>
        end
        C(:,j)=row_result;
    end
end
