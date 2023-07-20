function C1=stridedMatrixMultiplyFull(...
    TRANSA,...
    TRANSB,...
    alpha,...
    beta,...
    A,...
    B,...
    C,...
    m,n,k,...
    lda,ldb,ldc,...
    strideA,strideB,strideC,...
    batchCount)

%#codegen
    coder.allowpcode('plain');



    coder.internal.errorIf(numel(A)==0||numel(B)==0||numel(C)==0,'gpucoder:common:BatchedBlasMatrixWithAZeroDim');
    coder.internal.errorIf(~((7==nargin)||(17==nargin)),'gpucoder:common:BatchedBlasNumArgs',7,17);

    coder.internal.errorIf(~(strcmp(class(C),class(A))),'gpucoder:common:BatchedBlasDataTypeMismatch','A','C');
    coder.internal.errorIf(~(strcmp(class(C),class(B))),'gpucoder:common:BatchedBlasDataTypeMismatch','B','C');
    coder.internal.errorIf(~(strcmp(class(C),class(alpha))),'gpucoder:common:BatchedBlasDataTypeMismatch','alpha','C');
    coder.internal.errorIf(~(strcmp(class(C),class(beta))),'gpucoder:common:BatchedBlasDataTypeMismatch','beta','C');

    coder.internal.errorIf(~(('N'==TRANSA)||('T'==TRANSA)||('C'==TRANSA)),'gpucoder:common:BatchedBlasTransposeArg');
    coder.internal.errorIf(~(('N'==TRANSB)||('T'==TRANSB)||('C'==TRANSB)),'gpucoder:common:BatchedBlasTransposeArg');
    NOTA=('N'==TRANSA);
    NOTB=('N'==TRANSB);
    CONJA=('C'==TRANSA);
    CONJB=('C'==TRANSB);


    if nargin<8
        m=size(C,1);
        n=size(C,2);
        if NOTA

            coder.internal.errorIf(~(m==size(A,1)),'gpucoder:common:StridedBlasMatrixDimMismatch','size(A,1)','size(C,1)');
            k=size(A,2);
        else

            coder.internal.errorIf(~(m==size(A,2)),'gpucoder:common:StridedBlasMatrixDimMismatch','size(A,2)','size(C,1)');
            k=size(A,1);
        end
        if NOTB

            coder.internal.errorIf(~(n==size(B,2)),'gpucoder:common:StridedBlasMatrixDimMismatch','size(B,2)','size(C,2)');
            coder.internal.errorIf(~(k==size(B,1)),'gpucoder:common:StridedBlasMatrixDimMismatch','size(B,1)',k);
        else

            coder.internal.errorIf(~(n==size(B,1)),'gpucoder:common:StridedBlasMatrixDimMismatch','size(B,1)','size(C,2)');
            coder.internal.errorIf(~(k==size(B,2)),'gpucoder:common:StridedBlasMatrixDimMismatch','size(B,1)',k);
        end
        lda=size(A,1);
        ldb=size(B,1);
        ldc=size(C,1);
        batchDimsA=size(A);
        batchDimsA=batchDimsA(3:end);
        batchDimsB=size(B);
        batchDimsB=batchDimsB(3:end);
        batchDimsC=size(C);
        batchDimsC=batchDimsC(3:end);
        if 1<prod(batchDimsA)
            if 1<prod(batchDimsB)
                coder.internal.errorIf(~(numel(batchDimsA)==numel(batchDimsB)),'gpucoder:common:StridedBlasMatrixDimMismatch','ndims(A)','ndims(B)');
                coder.internal.errorIf(~(all(batchDimsA==batchDimsB)),'gpucoder:common:StridedBlasMatrixDimMismatch','size(A,3:end)','size(B,3:end)');
            end
            if 1<prod(batchDimsC)
                coder.internal.errorIf(~(numel(batchDimsA)==numel(batchDimsC)),'gpucoder:common:StridedBlasMatrixDimMismatch','ndims(A)','ndims(C)');
                coder.internal.errorIf(~(all(batchDimsA==batchDimsC)),'gpucoder:common:StridedBlasMatrixDimMismatch','size(A,3:end)','size(C,3:end)');
            end
            strideA=m.*k;
        else
            strideA=0;
        end
        if 1<prod(batchDimsB)
            if 1<prod(batchDimsC)
                coder.internal.errorIf(~(numel(batchDimsB)==numel(batchDimsC)),'gpucoder:common:StridedBlasMatrixDimMismatch','ndims(B)','ndims(C)');
                coder.internal.errorIf(~(all(batchDimsB==batchDimsC)),'gpucoder:common:StridedBlasMatrixDimMismatch','size(B,3:end)','size(C,3:end)');
            end
            strideB=k.*n;
        else
            strideB=0;
        end
        if 1==prod(batchDimsC)
            if 1<prod(batchDimsA)
                C1=repmat(C,[1,1,batchDimsA]);
            elseif 1<prod(batchDimsB)
                C1=repmat(C,[1,1,batchDimsB]);
            else
                C1=C;
            end
        else
            C1=C;
        end
        strideC=m.*n;

        if prod(batchDimsA)>=prod(batchDimsB)
            if prod(batchDimsA)>=prod(batchDimsC)
                batchCount=prod(batchDimsA);
            else
                batchCount=prod(batchDimsC);
            end
        else
            if prod(batchDimsB)>=prod(batchDimsC)
                batchCount=prod(batchDimsB);
            else
                batchCount=prod(batchDimsC);
            end
        end

    else
        C1=C;
    end

    if NOTA
        largest_ind=strideA*(batchCount-1)+lda*(k-1)+(m-1);
        coder.internal.errorIf(~(largest_ind<numel(A)),'gpucoder:common:BatchedBlasIndexOverflow','Largest Index',largest_ind,'numel(A)',numel(A));
    else
        largest_ind=strideA*(batchCount-1)+lda*(m-1)+(k-1);
        coder.internal.errorIf(~(largest_ind<numel(A)),'gpucoder:common:BatchedBlasIndexOverflow','Largest Index',largest_ind,'numel(A)',numel(A));
    end
    if NOTB
        largest_ind=strideB*(batchCount-1)+ldb*(n-1)+(k-1);
        coder.internal.errorIf(~(largest_ind<numel(B)),'gpucoder:common:BatchedBlasIndexOverflow','Largest Index',largest_ind,'numel(B)',numel(B));
    else
        largest_ind=strideB*(batchCount-1)+ldb*(k-1)+(n-1);
        coder.internal.errorIf(~(largest_ind<numel(B)),'gpucoder:common:BatchedBlasIndexOverflow','Largest Index',largest_ind,'numel(B)',numel(B));
    end
    largest_ind=strideC*(batchCount-1)+ldc*(n-1)+(m-1);
    coder.internal.errorIf(~(largest_ind<numel(C1)),'gpucoder:common:BatchedBlasIndexOverflow','Largest Index',largest_ind,'numel(C1)',numel(C1));

    if coder.target('MATLAB')
        matsizeA=size(A,1)*size(A,2);
        matsizeB=size(B,1)*size(B,2);
        matsizeC=size(C1,1)*size(C1,2);

        if(0==mod(strideA,matsizeA))&&(0==mod(strideB,matsizeB))&&...
            (0==mod(strideC,matsizeC))&&(0==mod(lda,size(A,1)))&&...
            ((NOTA&&(k*lda<=matsizeA)&&(m<=size(A,1)))||...
            ((~NOTA)&&(m*lda<=matsizeA)&&(k<=size(A,1))))&&...
            (0==mod(ldb,size(B,1)))&&...
            ((NOTB&&(n*ldb<=matsizeB)&&(k<=size(B,1)))||...
            ((~NOTB)&&(k*ldb<=matsizeB)&&(n<=size(B,1))))&&...
            (0==mod(ldc,size(C1,1)))&&...
            (n*ldc<=matsizeC)&&(m<=size(C1,1))
            dA3=strideA/matsizeA;
            dB3=strideB/matsizeB;
            dC3=strideC/matsizeC;
            dA2=lda/size(A,1);
            dB2=ldb/size(B,1);
            dC2=ldc/size(C1,1);
            if(1==dA2)&&(1==dB2)&&...
                ((NOTA&&(size(A,1)==m)&&(size(A,2)==k))||...
                ((~NOTA)&&(size(A,2)==m)&&(size(A,1)==k)))&&...
                ((NOTB&&(size(B,1)==k)&&(size(B,2)==n))||...
                ((~NOTB)&&(size(B,2)==k)&&(size(B,1)==n)))
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
            else
                if NOTA
                    opA=@(submat,m,k,dA2)submat(1:m,1:dA2:k);
                elseif CONJA
                    opA=@(submat,m,k,dA2)(submat(1:k,1:dA2:m))';
                else
                    opA=@(submat,m,k,dA2)(submat(1:k,1:dA2:m)).';
                end
                if NOTB
                    opB=@(submat,k,n,dB2)submat(1:k,1:dB2:n);
                elseif CONJB
                    opB=@(submat,k,n,dB2)(submat(1:n,1:dB2:k))';
                else
                    opB=@(submat,k,n,dB2)(submat(1:n,1:dB2:k)).';
                end
            end
            for i=0:batchCount-1
                C1(1:m,1:dC2:n,i*dC3+1)=alpha.*opA(A(:,:,i*dA3+1))*opB(B(:,:,i*dB3+1))+...
                beta.*C1(1:m,1:dC2:n,i*dC3+1);
            end
        else
            Coffset=0;
            Aoffset=0;
            Boffset=0;
            lastBatchC=Coffset+(strideC.*(batchCount-1));
            lastColC_=ldc.*(n-1);

            if beta==0
                for batch_Coffset=Coffset:strideC:lastBatchC
                    for cr=batch_Coffset:ldc:(batch_Coffset+lastColC_)
                        for ic=(cr+1):(cr+m)
                            C1(ic)=0;
                        end
                    end
                end
            else
                for batch_Coffset=Coffset:strideC:lastBatchC
                    for cr=batch_Coffset:ldc:(batch_Coffset+lastColC_)
                        for ic=(cr+1):(cr+m)
                            C1(ic)=C1(ic).*beta;
                        end
                    end
                end
            end

            if alpha==0
                return
            end

            if NOTB
                if NOTA

                    batch_Boffset=Boffset;
                    batch_Aoffset=Aoffset;
                    for batch_Coffset=Coffset:strideC:lastBatchC
                        br=batch_Boffset;
                        for cr=batch_Coffset:ldc:(batch_Coffset+lastColC_)
                            ar=batch_Aoffset;
                            for ib=(br+1):(br+k)
                                temp=alpha.*B(ib);
                                ia=ar;
                                for ic=(cr+1):(cr+m)
                                    ia=(ia+1);
                                    C1(ic)=C1(ic)+temp.*A(ia);
                                end
                                ar=(ar+lda);
                            end
                            br=(br+ldb);
                        end
                        batch_Boffset=(batch_Boffset+strideB);
                        batch_Aoffset=(batch_Aoffset+strideA);
                    end
                else


                    batch_Boffset=Boffset;
                    batch_Aoffset=Aoffset;
                    for batch_Coffset=Coffset:strideC:lastBatchC
                        br=batch_Boffset;
                        for cr=batch_Coffset:ldc:(batch_Coffset+lastColC_)
                            ar=batch_Aoffset;
                            for ic=(cr+1):(cr+m)
                                temp=0;
                                for w=1:k
                                    if CONJA
                                        temp=temp+(conj(A(w+ar)).*B(w+br));
                                    else
                                        temp=temp+A(w+ar).*B(w+br);
                                    end
                                end
                                C1(ic)=C1(ic)+alpha.*temp;
                                ar=(ar+lda);
                            end
                            br=(br+ldb);
                        end
                        batch_Boffset=(batch_Boffset+strideB);
                        batch_Aoffset=(batch_Aoffset+strideA);
                    end
                end
            elseif NOTA


                batch_Boffset=Boffset;
                batch_Aoffset=Aoffset;
                for batch_Coffset=Coffset:strideC:lastBatchC
                    br=batch_Boffset;
                    for cr=batch_Coffset:ldc:(batch_Coffset+lastColC_)
                        ar=batch_Aoffset;
                        br=(br+1);
                        for ib=br:ldb:(br+(ldb.*(k-1)))
                            if CONJB
                                temp=alpha.*conj(B(ib));
                            else
                                temp=alpha.*B(ib);
                            end
                            ia=ar;
                            for ic=(cr+1):(cr+m)
                                ia=(ia+1);
                                C1(ic)=C1(ic)+temp.*A(ia);
                            end
                            ar=(ar+lda);
                        end
                    end
                    batch_Boffset=(batch_Boffset+strideB);
                    batch_Aoffset=(batch_Aoffset+strideA);
                end
            else




                batch_Boffset=Boffset;
                batch_Aoffset=Aoffset;
                for batch_Coffset=Coffset:strideC:lastBatchC
                    br=batch_Boffset;
                    for cr=batch_Coffset:ldc:(batch_Coffset+lastColC_)
                        ar=batch_Aoffset;
                        br=(br+1);
                        for ic=(cr+1):(cr+m)
                            temp=0;
                            ib=br;
                            for ia=(ar+1):(ar+k)
                                if CONJA==CONJB
                                    temp=temp+A(ia).*B(ib);
                                elseif CONJA
                                    temp=temp+(conj(A(ia)).*B(ib));
                                else
                                    temp=temp+(conj(B(ib)).*A(ia));
                                end
                                ib=(ib+ldb);
                            end
                            if CONJA&&CONJB
                                C1(ic)=C1(ic)+(conj(temp).*alpha);
                            else
                                C1(ic)=C1(ic)+alpha.*temp;
                            end
                            ar=(ar+lda);
                        end
                    end
                    batch_Boffset=(batch_Boffset+strideB);
                    batch_Aoffset=(batch_Aoffset+strideA);
                end
            end
        end
    else
        ia0=coder.internal.indexInt(1);
        ib0=coder.internal.indexInt(1);
        ic0=coder.internal.indexInt(1);
        C1=coder.internal.blas.xgemmStridedBatched(...
        TRANSA,...
        TRANSB,...
        m,n,k,...
        alpha,...
        A,ia0,lda,...
        strideA,...
        B,ib0,ldb,...
        strideB,...
        beta,...
        C1,ic0,ldc,...
        strideC,...
        batchCount);
    end

end
