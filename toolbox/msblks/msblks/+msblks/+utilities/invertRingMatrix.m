





















function[Ainv,d]=invertRingMatrix(A,I,zero)
    [nr,nc]=size(A);
    if nr~=nc
        fprintf('Gauss-Kormylo Reduction needs a square matrix to invert.\n');
        return;
    end

    d=I(1,1);
    Ainv=I;

    indxc=zeros(nr,1);
    indxr=zeros(nr,1);
    ipiv=zeros(nr,1);
    for i=1:nr

        big=zero;
        icol=0;
        for j=1:nr
            if ipiv(j)~=1
                for k=1:nr
                    if ipiv(k)==0
                        if A(j,k)>zero&&A(j,k)>big
                            big=A(j,k);
                            irow=j;
                            icol=k;
                        elseif A(j,k)<zero&&-A(j,k)>big
                            big=-A(j,k);
                            irow=j;
                            icol=k;
                        end
                    end
                end
            end
        end

        if icol==0||A(irow,icol)==zero
            fprintf('Singular matrix submitted to Gauss-Kormylo Reduction.\n');
            return;
        end

        ipiv(icol)=1;
        indxr(i)=irow;
        indxc(i)=icol;

        if irow~=icol
            tmp=A(irow,:);
            A(irow,:)=A(icol,:);
            A(icol,:)=tmp;
            tmp=Ainv(irow,:);
            Ainv(irow,:)=Ainv(icol,:);
            Ainv(icol,:)=tmp;
        end

        for ll=1:nr
            if ll~=icol
                dum=A(ll,icol);
                A(ll,:)=(A(icol,icol)*A(ll,:)-dum*A(icol,:))/d;
                Ainv(ll,:)=(A(icol,icol)*Ainv(ll,:)-dum*Ainv(icol,:))/d;
            end
        end

        d=A(icol,icol);
    end
end