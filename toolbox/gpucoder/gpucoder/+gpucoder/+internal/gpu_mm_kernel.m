%#codegen
function C=gpu_mm_kernel(func,A,B,varargin)






    coder.inline('always');
    coder.allowpcode('plain');
    coder.gpu.internal.kernelfunImpl(false);

    coder.internal.assert((nargin==3)||(nargin==4),'gpucoder:common:MMKernelWrongNumArgs','gpucoder.matrixMatrixKernel',nargin);
    if(numel(varargin)==0)
        coder.internal.assert(size(A,2)==size(B,1),'gpucoder:common:MMKernelIncompatDims');
        if coder.isRowMajor
            C=gpu_mm_kernel_tt(func,A',B',true)';
        else
            C=gpu_mm_kernel_nn(func,A,B,false);
        end
        return
    end

    switch lower(varargin{1})
    case 'nn'
        coder.internal.assert(size(A,2)==size(B,1),'gpucoder:common:MMKernelIncompatDims');
        if coder.isRowMajor
            C=gpu_mm_kernel_tt(func,A',B',true)';
        else
            C=gpu_mm_kernel_nn(func,A,B,false);
        end
    case 'nt'
        coder.internal.assert(size(A,2)==size(B,2),'gpucoder:common:MMKernelIncompatDims');
        if coder.isRowMajor
            C=gpu_mm_kernel_tn(func,A',B',true)';
        else
            C=gpu_mm_kernel_nt(func,A,B,false);
        end
    case 'tn'
        coder.internal.assert(size(A,1)==size(B,1),'gpucoder:common:MMKernelIncompatDims');
        if coder.isRowMajor
            C=gpu_mm_kernel_nt(func,A',B',true)';
        else
            C=gpu_mm_kernel_tn(func,A,B,false);
        end
    case 'tt'
        coder.internal.assert(size(A,1)==size(B,2),'gpucoder:common:MMKernelIncompatDims');
        if coder.isRowMajor
            C=gpu_mm_kernel_nn(func,A',B',true)';
        else
            C=gpu_mm_kernel_tt(func,A,B,false);
        end
    otherwise
        coder.internal.assert(false,'gpucoder:common:MMKernelInvalidTrans','''nn'', ''nt'', ''tn'', or ''tt''');
    end
end






function C=gpu_mm_kernel_nn(func,A,B,transposeOutput)
    coder.columnMajor;
    coder.inline('always');
    coder.gpu.internal.kernelfunImpl(false);

    DIM_X=int32(16);
    DIM_Y=int32(16);
    BLK_M=int32(64);
    BLK_N=int32(64);
    BLK_K=int32(16);
    DIM_XA=int32(16);
    DIM_YA=int32(16);
    DIM_XB=int32(16);
    DIM_YB=int32(16);
    THR_M=BLK_M/DIM_X;
    THR_N=BLK_N/DIM_Y;

    M=int32(size(A,1));
    N=int32(size(B,2));
    K=int32(size(A,2));
    LDA=int32(size(A,1));
    LDB=int32(size(B,1));

    coder.internal.assert(coder.internal.isConst(M),'gpucoder:common:MMKernelNonConstDim',1,'A');
    coder.internal.assert(coder.internal.isConst(N),'gpucoder:common:MMKernelNonConstDim',2,'B');

    bx=coder.const(idivide(M,BLK_M,'ceil'));
    by=coder.const(idivide(N,BLK_N,'ceil'));

    if transposeOutput
        C=zeros(N,M,'like',A);
    else
        C=zeros(M,N,'like',A);
    end

    MAX_BLOCKS_PER_GRID_DIM=coder.const(65535);
    coder.internal.assert(bx<MAX_BLOCKS_PER_GRID_DIM,'gpucoder:common:MMKernelSizeTooLarge',1,'A');
    coder.internal.assert(by<MAX_BLOCKS_PER_GRID_DIM,'gpucoder:common:MMKernelSizeTooLarge',2,'B');

    coder.gpu.internal.kernelImpl(false,[bx,by,1],[DIM_X,DIM_Y,1]);
    for i=1:by*DIM_Y
        coder.gpu.internal.kernelImpl(false);
        for j=1:bx*DIM_X
            coder.gpu.internal.noKernelRegion;
            idx=int32(0);
            idy=int32(0);
            blx=int32(0);
            bly=int32(0);

            idx=coder.ceval('__gpu_threadIdx_x');
            idy=coder.ceval('__gpu_threadIdx_y');
            blx=coder.ceval('__gpu_blockIdx_x');
            bly=coder.ceval('__gpu_blockIdx_y');

            idt=DIM_X*idy+idx;


            idxA=mod(idt,DIM_XA);
            idyA=idivide(idt,DIM_XA);

            idxB=mod(idt,DIM_XB);
            idyB=idivide(idt,DIM_XB);


            sA=coder.nullcopy(zeros(BLK_M+1,BLK_K,'like',A));
            sB=coder.nullcopy(zeros(BLK_K+1,BLK_N,'like',B));
            coder.ceval('-preservearraydims','__gpu_smem',coder.ref(sA));
            coder.ceval('-preservearraydims','__gpu_smem',coder.ref(sB));



            rC=coder.nullcopy(zeros(THR_M,THR_N,'like',A));
            rA=coder.nullcopy(zeros(THR_M,1,'like',A));
            rB=coder.nullcopy(zeros(THR_N,1,'like',B));

            ra=coder.nullcopy(zeros(BLK_M/DIM_YA,BLK_K/DIM_XA,'like',A));
            rb=coder.nullcopy(zeros(BLK_K/DIM_YB,BLK_N/DIM_XB,'like',B));

            offsetA=blx*BLK_M+idyA*LDA+idxA;
            boundA=(LDA*(K-1)+M)-(blx*BLK_M+idyA*LDA+idxA)-1;

            offsetB=bly*BLK_N*LDB+idyB*LDB+idxB;
            boundB=(LDB*(N-1)+K)-(bly*BLK_N*LDB+idyB*LDB+idxB)-1;

            for n=1:THR_N
                for m=1:THR_M
                    rC(m,n)=0.0;
                end
            end


            for n=0:DIM_YA:(BLK_K-1)
                for m=0:DIM_XA:(BLK_M-1)
                    sA(m+idxA+1,n+idyA+1)=fetch(A,offsetA,m,n,boundA);
                end
            end

            for n=0:DIM_YB:(BLK_N-1)
                for m=0:DIM_XB:(BLK_K-1)
                    sB(m+idxB+1,n+idyB+1)=fetch(B,offsetB,m,n,boundB);
                end
            end

            coder.ceval('__syncthreads');

            kk=int32(0);
            while(kk<K-BLK_K)
                offsetA=offsetA+BLK_K*LDA;
                boundA=boundA-BLK_K*LDA;

                offsetB=offsetB+BLK_K;
                boundB=boundB-BLK_K;


                for n=0:(BLK_K/DIM_YA-1)
                    for m=0:(BLK_M/DIM_XA-1)
                        ra(m+1,n+1)=fetch(A,offsetA,m*DIM_XA,n*DIM_YA,boundA);
                    end
                end

                for n=0:(BLK_N/DIM_YB-1)
                    for m=0:(BLK_K/DIM_XB-1)
                        rb(m+1,n+1)=fetch(B,offsetB,m*DIM_XB,n*DIM_YB,boundB);
                    end
                end


                for k=0:(BLK_K-1)
                    for m=0:(THR_M-1)
                        rA(m+1)=sA(m*DIM_X+idx+1,k+1);
                    end

                    for n=0:(THR_N-1)
                        rB(n+1)=sB(k+1,n*DIM_Y+idy+1);
                    end

                    for n=0:(THR_N-1)
                        for m=0:(THR_M-1)
                            rC(m+1,n+1)=rC(m+1,n+1)+func(rA(m+1),rB(n+1));
                        end
                    end
                end

                coder.ceval('__syncthreads');


                for n=0:(BLK_K/DIM_YA-1)
                    for m=0:(BLK_M/DIM_XA-1)
                        sA(m*DIM_XA+idxA+1,n*DIM_YA+idyA+1)=ra(m+1,n+1);
                    end
                end

                for n=0:(BLK_N/DIM_YB-1)
                    for m=0:(BLK_K/DIM_XB-1)
                        sB(m*DIM_XB+idxB+1,n*DIM_YB+idyB+1)=rb(m+1,n+1);
                    end
                end

                coder.ceval('__syncthreads');
                kk=kk+BLK_K;
            end

            kk=K-kk;
            for k=0:(kk-1)
                for m=0:(THR_M-1)
                    rA(m+1)=sA(m*DIM_X+idx+1,k+1);
                end

                for n=0:(THR_N-1)
                    rB(n+1)=sB(k+1,n*DIM_Y+idy+1);
                end

                for n=0:(THR_N-1)
                    for m=0:(THR_M-1)
                        rC(m+1,n+1)=rC(m+1,n+1)+func(rA(m+1),rB(n+1));
                    end
                end
            end

            for n=0:(THR_N-1)
                coord_dCn=bly*BLK_N+n*DIM_Y+idy;
                for m=0:(THR_M-1)
                    coord_dCm=blx*BLK_M+m*DIM_X+idx;
                    if(coord_dCm<M&&coord_dCn<N)
                        if transposeOutput
                            C(coord_dCn+1,coord_dCm+1)=C(coord_dCn+1,coord_dCm+1)+rC(m+1,n+1);
                        else
                            C(coord_dCm+1,coord_dCn+1)=C(coord_dCm+1,coord_dCn+1)+rC(m+1,n+1);
                        end
                    end
                end
            end
        end
    end

end

function C=gpu_mm_kernel_nt(func,A,B,transposeOutput)
    coder.columnMajor;
    coder.inline('always');
    coder.gpu.internal.kernelfunImpl(false);

    DIM_X=int32(16);
    DIM_Y=int32(16);
    BLK_M=int32(64);
    BLK_N=int32(64);
    BLK_K=int32(16);
    DIM_XA=int32(16);
    DIM_YA=int32(16);
    DIM_XB=int32(16);
    DIM_YB=int32(16);
    THR_M=BLK_M/DIM_X;
    THR_N=BLK_N/DIM_Y;

    M=int32(size(A,1));
    N=int32(size(B,1));
    K=int32(size(A,2));
    LDA=int32(size(A,1));
    LDB=int32(size(B,1));

    coder.internal.assert(coder.internal.isConst(M),'gpucoder:common:MMKernelNonConstDim',1,'A');
    coder.internal.assert(coder.internal.isConst(N),'gpucoder:common:MMKernelNonConstDim',1,'B');
    bx=coder.const(idivide(M,BLK_M,'ceil'));
    by=coder.const(idivide(N,BLK_N,'ceil'));

    if transposeOutput
        C=zeros(N,M,'like',A);
    else
        C=zeros(M,N,'like',A);
    end

    MAX_BLOCKS_PER_GRID_DIM=coder.const(65535);
    coder.internal.assert(bx<MAX_BLOCKS_PER_GRID_DIM,'gpucoder:common:MMKernelSizeTooLarge',1,'A');
    coder.internal.assert(by<MAX_BLOCKS_PER_GRID_DIM,'gpucoder:common:MMKernelSizeTooLarge',1,'B');

    coder.gpu.internal.kernelImpl(false,[bx,by,1],[DIM_X,DIM_Y,1]);
    for i=1:by*DIM_Y
        coder.gpu.internal.kernelImpl(false);
        for j=1:bx*DIM_X
            coder.gpu.internal.noKernelRegion;
            idx=int32(0);
            idy=int32(0);
            blx=int32(0);
            bly=int32(0);

            idx=coder.ceval('__gpu_threadIdx_x');
            idy=coder.ceval('__gpu_threadIdx_y');
            blx=coder.ceval('__gpu_blockIdx_x');
            bly=coder.ceval('__gpu_blockIdx_y');

            idt=DIM_X*idy+idx;

            idxA=mod(idt,DIM_XA);
            idyA=idivide(idt,DIM_XA);

            idxB=mod(idt,DIM_XB);
            idyB=idivide(idt,DIM_XB);

            sA=coder.nullcopy(zeros(BLK_M+1,BLK_K,'like',A));
            sB=coder.nullcopy(zeros(BLK_K+1,BLK_N,'like',B));
            coder.ceval('-preservearraydims','__gpu_smem',coder.ref(sA));
            coder.ceval('-preservearraydims','__gpu_smem',coder.ref(sB));

            rC=coder.nullcopy(zeros(THR_M,THR_N,'like',A));
            rA=coder.nullcopy(zeros(THR_M,1,'like',A));
            rB=coder.nullcopy(zeros(THR_N,1,'like',B));

            ra=coder.nullcopy(zeros(BLK_M/DIM_YA,BLK_K/DIM_XA,'like',A));
            rb=coder.nullcopy(zeros(BLK_N/DIM_YB,BLK_K/DIM_XB,'like',B));

            offsetA=blx*BLK_M+idyA*LDA+idxA;
            boundA=(LDA*(K-1)+M)-(blx*BLK_M+idyA*LDA+idxA)-1;

            offsetB=bly*BLK_N+idyB*LDB+idxB;
            boundB=(LDB*(K-1)+N)-(bly*BLK_N+idyB*LDB+idxB)-1;

            for n=1:THR_N
                for m=1:THR_M
                    rC(m,n)=0.0;
                end
            end

            for n=0:DIM_YA:(BLK_K-1)
                for m=0:DIM_XA:(BLK_M-1)
                    sA(m+idxA+1,n+idyA+1)=fetch(A,offsetA,m,n,boundA);
                end
            end

            for n=0:DIM_YB:(BLK_K-1)
                for m=0:DIM_XB:(BLK_N-1)
                    sB(n+idyB+1,m+idxB+1)=fetch(B,offsetB,m,n,boundB);
                end
            end

            coder.ceval('__syncthreads');

            kk=int32(0);
            while(kk<K-BLK_K)
                offsetA=offsetA+BLK_K*LDA;
                boundA=boundA-BLK_K*LDA;

                offsetB=offsetB+BLK_K*LDB;
                boundB=boundB-BLK_K*LDB;

                for n=0:(BLK_K/DIM_YA-1)
                    for m=0:(BLK_M/DIM_XA-1)
                        ra(m+1,n+1)=fetch(A,offsetA,m*DIM_XA,n*DIM_YA,boundA);
                    end
                end

                for n=0:(BLK_K/DIM_YB-1)
                    for m=0:(BLK_N/DIM_XB-1)
                        rb(m+1,n+1)=fetch(B,offsetB,m*DIM_XB,n*DIM_YB,boundB);
                    end
                end

                for k=0:(BLK_K-1)
                    for m=0:(THR_M-1)
                        rA(m+1)=sA(m*DIM_X+idx+1,k+1);
                    end

                    for n=0:(THR_N-1)
                        rB(n+1)=sB(k+1,n*DIM_Y+idy+1);
                    end

                    for n=0:(THR_N-1)
                        for m=0:(THR_M-1)
                            rC(m+1,n+1)=rC(m+1,n+1)+func(rA(m+1),rB(n+1));
                        end
                    end
                end

                coder.ceval('__syncthreads');

                for n=0:(BLK_K/DIM_YA-1)
                    for m=0:(BLK_M/DIM_XA-1)
                        sA(m*DIM_XA+idxA+1,n*DIM_YA+idyA+1)=ra(m+1,n+1);
                    end
                end

                for n=0:(BLK_K/DIM_YB-1)
                    for m=0:(BLK_N/DIM_XB-1)
                        sB(n*DIM_YB+idyB+1,m*DIM_XB+idxB+1)=rb(m+1,n+1);
                    end
                end

                coder.ceval('__syncthreads');
                kk=kk+BLK_K;
            end

            kk=K-kk;
            for k=0:(kk-1)
                for m=0:(THR_M-1)
                    rA(m+1)=sA(m*DIM_X+idx+1,k+1);
                end

                for n=0:(THR_N-1)
                    rB(n+1)=sB(k+1,n*DIM_Y+idy+1);
                end

                for n=0:(THR_N-1)
                    for m=0:(THR_M-1)
                        rC(m+1,n+1)=rC(m+1,n+1)+func(rA(m+1),rB(n+1));
                    end
                end
            end

            for n=0:(THR_N-1)
                coord_dCn=bly*BLK_N+n*DIM_Y+idy;
                for m=0:(THR_M-1)
                    coord_dCm=blx*BLK_M+m*DIM_X+idx;
                    if(coord_dCm<M&&coord_dCn<N)
                        if transposeOutput
                            C(coord_dCn+1,coord_dCm+1)=C(coord_dCn+1,coord_dCm+1)+rC(m+1,n+1);
                        else
                            C(coord_dCm+1,coord_dCn+1)=C(coord_dCm+1,coord_dCn+1)+rC(m+1,n+1);
                        end
                    end
                end
            end
        end
    end

end

function C=gpu_mm_kernel_tn(func,A,B,transposeOutput)
    coder.columnMajor;
    coder.inline('always');
    coder.gpu.internal.kernelfunImpl(false);

    DIM_X=int32(16);
    DIM_Y=int32(16);
    BLK_M=int32(64);
    BLK_N=int32(64);
    BLK_K=int32(16);
    DIM_XA=int32(16);
    DIM_YA=int32(16);
    DIM_XB=int32(16);
    DIM_YB=int32(16);
    THR_M=BLK_M/DIM_X;
    THR_N=BLK_N/DIM_Y;

    M=int32(size(A,2));
    N=int32(size(B,2));
    K=int32(size(A,1));
    LDA=int32(size(A,1));
    LDB=int32(size(B,1));

    coder.internal.assert(coder.internal.isConst(M),'gpucoder:common:MMKernelNonConstDim',2,'A');
    coder.internal.assert(coder.internal.isConst(N),'gpucoder:common:MMKernelNonConstDim',2,'B');
    bx=coder.const(idivide(M,BLK_M,'ceil'));
    by=coder.const(idivide(N,BLK_N,'ceil'));

    if transposeOutput
        C=zeros(N,M,'like',A);
    else
        C=zeros(M,N,'like',A);
    end

    MAX_BLOCKS_PER_GRID_DIM=coder.const(65535);
    coder.internal.assert(bx<MAX_BLOCKS_PER_GRID_DIM,'gpucoder:common:MMKernelSizeTooLarge',2,'A');
    coder.internal.assert(by<MAX_BLOCKS_PER_GRID_DIM,'gpucoder:common:MMKernelSizeTooLarge',2,'B');

    coder.gpu.internal.kernelImpl(false,[bx,by,1],[DIM_X,DIM_Y,1]);
    for i=1:by*DIM_Y
        coder.gpu.internal.kernelImpl(false);
        for j=1:bx*DIM_X
            coder.gpu.internal.noKernelRegion;
            idx=int32(0);
            idy=int32(0);
            blx=int32(0);
            bly=int32(0);

            idx=coder.ceval('__gpu_threadIdx_x');
            idy=coder.ceval('__gpu_threadIdx_y');
            blx=coder.ceval('__gpu_blockIdx_x');
            bly=coder.ceval('__gpu_blockIdx_y');

            idt=DIM_X*idy+idx;

            idxA=mod(idt,DIM_XA);
            idyA=idivide(idt,DIM_XA);

            idxB=mod(idt,DIM_XB);
            idyB=idivide(idt,DIM_XB);

            sA=coder.nullcopy(zeros(BLK_M+1,BLK_K,'like',A));
            sB=coder.nullcopy(zeros(BLK_K+1,BLK_N,'like',B));
            coder.ceval('-preservearraydims','__gpu_smem',coder.ref(sA));
            coder.ceval('-preservearraydims','__gpu_smem',coder.ref(sB));

            rC=coder.nullcopy(zeros(THR_M,THR_N,'like',A));
            rA=coder.nullcopy(zeros(THR_M,1,'like',A));
            rB=coder.nullcopy(zeros(THR_N,1,'like',B));

            ra=coder.nullcopy(zeros(BLK_K/DIM_YA,BLK_M/DIM_XA,'like',A));
            rb=coder.nullcopy(zeros(BLK_K/DIM_YB,BLK_N/DIM_XB,'like',B));

            offsetA=blx*BLK_M*LDA+idyA*LDA+idxA;
            boundA=(LDA*(M-1)+K)-(blx*BLK_M*LDA+idyA*LDA+idxA)-1;

            offsetB=bly*BLK_N*LDB+idyB*LDB+idxB;
            boundB=(LDB*(N-1)+K)-(bly*BLK_N*LDB+idyB*LDB+idxB)-1;

            for n=1:THR_N
                for m=1:THR_M
                    rC(m,n)=0.0;
                end
            end

            for n=0:DIM_YA:(BLK_M-1)
                for m=0:DIM_XA:(BLK_K-1)
                    sA(n+idyA+1,m+idxA+1)=fetch(A,offsetA,m,n,boundA);
                end
            end

            for n=0:DIM_YB:(BLK_N-1)
                for m=0:DIM_XB:(BLK_K-1)
                    sB(m+idxB+1,n+idyB+1)=fetch(B,offsetB,m,n,boundB);
                end
            end

            coder.ceval('__syncthreads');

            kk=int32(0);
            while(kk<K-BLK_K)
                offsetA=offsetA+BLK_K;
                boundA=boundA-BLK_K;

                offsetB=offsetB+BLK_K;
                boundB=boundB-BLK_K;

                for n=0:(BLK_M/DIM_YA-1)
                    for m=0:(BLK_K/DIM_XA-1)
                        ra(m+1,n+1)=fetch(A,offsetA,m*DIM_XA,n*DIM_YA,boundA);
                    end
                end

                for n=0:(BLK_N/DIM_YB-1)
                    for m=0:(BLK_K/DIM_XB-1)
                        rb(m+1,n+1)=fetch(B,offsetB,m*DIM_XB,n*DIM_YB,boundB);
                    end
                end

                for k=0:(BLK_K-1)
                    for m=0:(THR_M-1)
                        rA(m+1)=sA(m*DIM_X+idx+1,k+1);
                    end

                    for n=0:(THR_N-1)
                        rB(n+1)=sB(k+1,n*DIM_Y+idy+1);
                    end

                    for n=0:(THR_N-1)
                        for m=0:(THR_M-1)
                            rC(m+1,n+1)=rC(m+1,n+1)+func(rA(m+1),rB(n+1));
                        end
                    end
                end

                coder.ceval('__syncthreads');

                for n=0:(BLK_M/DIM_YA-1)
                    for m=0:(BLK_K/DIM_XA-1)
                        sA(n*DIM_YA+idyA+1,m*DIM_XA+idxA+1)=ra(m+1,n+1);
                    end
                end

                for n=0:(BLK_N/DIM_YB-1)
                    for m=0:(BLK_K/DIM_XB-1)
                        sB(m*DIM_XB+idxB+1,n*DIM_YB+idyB+1)=rb(m+1,n+1);
                    end
                end

                coder.ceval('__syncthreads');
                kk=kk+BLK_K;
            end

            kk=K-kk;
            for k=0:(kk-1)
                for m=0:(THR_M-1)
                    rA(m+1)=sA(m*DIM_X+idx+1,k+1);
                end

                for n=0:(THR_N-1)
                    rB(n+1)=sB(k+1,n*DIM_Y+idy+1);
                end

                for n=0:(THR_N-1)
                    for m=0:(THR_M-1)
                        rC(m+1,n+1)=rC(m+1,n+1)+func(rA(m+1),rB(n+1));
                    end
                end
            end

            for n=0:(THR_N-1)
                coord_dCn=bly*BLK_N+n*DIM_Y+idy;
                for m=0:(THR_M-1)
                    coord_dCm=blx*BLK_M+m*DIM_X+idx;
                    if(coord_dCm<M&&coord_dCn<N)
                        if transposeOutput
                            C(coord_dCn+1,coord_dCm+1)=C(coord_dCn+1,coord_dCm+1)+rC(m+1,n+1);
                        else
                            C(coord_dCm+1,coord_dCn+1)=C(coord_dCm+1,coord_dCn+1)+rC(m+1,n+1);
                        end
                    end
                end
            end
        end
    end

end

function C=gpu_mm_kernel_tt(func,A,B,transposeOutput)
    coder.columnMajor;
    coder.inline('always');
    coder.gpu.internal.kernelfunImpl(false);

    DIM_X=int32(16);
    DIM_Y=int32(16);
    BLK_M=int32(64);
    BLK_N=int32(64);
    BLK_K=int32(16);
    DIM_XA=int32(16);
    DIM_YA=int32(16);
    DIM_XB=int32(16);
    DIM_YB=int32(16);
    THR_M=BLK_M/DIM_X;
    THR_N=BLK_N/DIM_Y;

    M=int32(size(A,2));
    N=int32(size(B,1));
    K=int32(size(A,1));
    LDA=int32(size(A,1));
    LDB=int32(size(B,1));

    coder.internal.assert(coder.internal.isConst(M),'gpucoder:common:MMKernelNonConstDim',2,'A');
    coder.internal.assert(coder.internal.isConst(N),'gpucoder:common:MMKernelNonConstDim',1,'B');
    bx=coder.const(idivide(M,BLK_M,'ceil'));
    by=coder.const(idivide(N,BLK_N,'ceil'));

    if transposeOutput
        C=zeros(N,M,'like',A);
    else
        C=zeros(M,N,'like',A);
    end

    MAX_BLOCKS_PER_GRID_DIM=coder.const(65535);
    coder.internal.assert(bx<MAX_BLOCKS_PER_GRID_DIM,'gpucoder:common:MMKernelSizeTooLarge',2,'A');
    coder.internal.assert(by<MAX_BLOCKS_PER_GRID_DIM,'gpucoder:common:MMKernelSizeTooLarge',1,'B');

    coder.gpu.internal.kernelImpl(false,[bx,by,1],[DIM_X,DIM_Y,1]);
    for i=1:by*DIM_Y
        coder.gpu.internal.kernelImpl(false);
        for j=1:bx*DIM_X
            coder.gpu.internal.noKernelRegion;
            idx=int32(0);
            idy=int32(0);
            blx=int32(0);
            bly=int32(0);

            idx=coder.ceval('__gpu_threadIdx_x');
            idy=coder.ceval('__gpu_threadIdx_y');
            blx=coder.ceval('__gpu_blockIdx_x');
            bly=coder.ceval('__gpu_blockIdx_y');

            idt=DIM_X*idy+idx;

            idxA=mod(idt,DIM_XA);
            idyA=idivide(idt,DIM_XA);

            idxB=mod(idt,DIM_XB);
            idyB=idivide(idt,DIM_XB);

            sA=coder.nullcopy(zeros(BLK_M+1,BLK_K,'like',A));
            sB=coder.nullcopy(zeros(BLK_K+1,BLK_N,'like',B));
            coder.ceval('-preservearraydims','__gpu_smem',coder.ref(sA));
            coder.ceval('-preservearraydims','__gpu_smem',coder.ref(sB));

            rC=coder.nullcopy(zeros(THR_M,THR_N,'like',A));
            rA=coder.nullcopy(zeros(THR_M,1,'like',A));
            rB=coder.nullcopy(zeros(THR_N,1,'like',B));

            ra=coder.nullcopy(zeros(BLK_K/DIM_YA,BLK_M/DIM_XA,'like',A));
            rb=coder.nullcopy(zeros(BLK_N/DIM_YB,BLK_K/DIM_XB,'like',B));

            offsetA=blx*BLK_M*LDA+idyA*LDA+idxA;
            boundA=(LDA*(M-1)+K)-(blx*BLK_M*LDA+idyA*LDA+idxA)-1;

            offsetB=bly*BLK_N+idyB*LDB+idxB;
            boundB=(LDB*(K-1)+N)-(bly*BLK_N+idyB*LDB+idxB)-1;

            for n=1:THR_N
                for m=1:THR_M
                    rC(m,n)=0.0;
                end
            end

            for n=0:DIM_YA:(BLK_M-1)
                for m=0:DIM_XA:(BLK_K-1)
                    sA(n+idyA+1,m+idxA+1)=fetch(A,offsetA,m,n,boundA);
                end
            end

            for n=0:DIM_YB:(BLK_K-1)
                for m=0:DIM_XB:(BLK_N-1)
                    sB(n+idyB+1,m+idxB+1)=fetch(B,offsetB,m,n,boundB);
                end
            end

            coder.ceval('__syncthreads');

            kk=int32(0);
            while(kk<K-BLK_K)
                offsetA=offsetA+BLK_K;
                boundA=boundA-BLK_K;

                offsetB=offsetB+BLK_K*LDB;
                boundB=boundB-BLK_K*LDB;

                for n=0:(BLK_M/DIM_YA-1)
                    for m=0:(BLK_K/DIM_XA-1)
                        ra(m+1,n+1)=fetch(A,offsetA,m*DIM_XA,n*DIM_YA,boundA);
                    end
                end

                for n=0:(BLK_K/DIM_YB-1)
                    for m=0:(BLK_N/DIM_XB-1)
                        rb(m+1,n+1)=fetch(B,offsetB,m*DIM_XB,n*DIM_YB,boundB);
                    end
                end

                for k=0:(BLK_K-1)
                    for m=0:(THR_M-1)
                        rA(m+1)=sA(m*DIM_X+idx+1,k+1);
                    end

                    for n=0:(THR_N-1)
                        rB(n+1)=sB(k+1,n*DIM_Y+idy+1);
                    end

                    for n=0:(THR_N-1)
                        for m=0:(THR_M-1)
                            rC(m+1,n+1)=rC(m+1,n+1)+func(rA(m+1),rB(n+1));
                        end
                    end
                end

                coder.ceval('__syncthreads');

                for n=0:(BLK_M/DIM_YA-1)
                    for m=0:(BLK_K/DIM_XA-1)
                        sA(n*DIM_YA+idyA+1,m*DIM_XA+idxA+1)=ra(m+1,n+1);
                    end
                end

                for n=0:(BLK_K/DIM_YB-1)
                    for m=0:(BLK_N/DIM_XB-1)
                        sB(n*DIM_YB+idyB+1,m*DIM_XB+idxB+1)=rb(m+1,n+1);
                    end
                end

                coder.ceval('__syncthreads');
                kk=kk+BLK_K;
            end

            kk=K-kk;
            for k=0:(kk-1)
                for m=0:(THR_M-1)
                    rA(m+1)=sA(m*DIM_X+idx+1,k+1);
                end

                for n=0:(THR_N-1)
                    rB(n+1)=sB(k+1,n*DIM_Y+idy+1);
                end

                for n=0:(THR_N-1)
                    for m=0:(THR_M-1)
                        rC(m+1,n+1)=rC(m+1,n+1)+func(rA(m+1),rB(n+1));
                    end
                end
            end

            for n=0:(THR_N-1)
                coord_dCn=bly*BLK_N+n*DIM_Y+idy;
                for m=0:(THR_M-1)
                    coord_dCm=blx*BLK_M+m*DIM_X+idx;
                    if(coord_dCm<M&&coord_dCn<N)
                        if transposeOutput
                            C(coord_dCn+1,coord_dCm+1)=C(coord_dCn+1,coord_dCm+1)+rC(m+1,n+1);
                        else
                            C(coord_dCm+1,coord_dCn+1)=C(coord_dCm+1,coord_dCn+1)+rC(m+1,n+1);
                        end
                    end
                end
            end
        end
    end

end





function result=fetch(A,offset,m,n,bound)
    coder.inline('always');
    idx=min(int32(n*size(A,1)+m),int32(bound));
    result=A(offset+idx+1);
end
