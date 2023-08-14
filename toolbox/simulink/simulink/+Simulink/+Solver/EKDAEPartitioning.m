function rowIdx=EKDAEPartitioning(M,J,mu)







    szA=size(J,1);
    A=J+(1/mu).*(eye(szA)-M);


    if szA==1
        if abs(A)>=1/mu
            rowIdx=[1];%#ok stiff case
        else
            rowIdx=[];
        end
        return;
    end


    rowOrd=1:szA;


    nss=1;
    [A,rowOrd]=pivoting(A,rowOrd,nss);

    while(normSpectralRadius(A,nss,mu)>=1)&&(nss<=szA)
        A=HessenbergHouseholderReflection(A,nss);
        nss=nss+1;
        [A,rowOrd]=pivoting(A,rowOrd,nss);
    end

    rowIdx=rowOrd(1,1:nss-1);
end

function rho=normSpectralRadius(A,nss,mu)

    szA=size(A,1);
    normH22=norm(A(nss+1:szA,nss+1:szA),'fro');
    b=A(nss+1:szA,nss);

    H11=eye(nss)-mu.*A(1:nss,1:nss);
    rhsH=A(1:nss,nss+1:szA)*[b,A(nss+1:szA,nss+1:szA)];

    B12=-mu.*(H11\rhsH);
    x=B12(nss,:)';
    rho=abs(mu)*sqrt(normH22*normH22+norm(b,2)*norm(b,2)+norm(x,2)*norm(x,2));
end

function[A,rowOrd]=pivoting(A,rowOrd,nss)

    szA=size(A,1);
    rowNorms=vecnorm(A(nss:szA,nss:szA));

    [~,pivot]=max(rowNorms);

    if pivot~=nss
        tmpPivot=rowOrd(1,nss);
        rowOrd(1,nss)=rowOrd(1,pivot);
        rowOrd(1,pivot)=tmpPivot;
        tmpRow=A(pivot,nss:szA);
        A(pivot,nss:szA)=A(nss,nss:szA);
        A(nss,nss:szA)=tmpRow;
        tmpCol=A(nss:szA,pivot);
        A(nss:szA,pivot)=A(nss:szA,nss);
        A(nss:szA,nss)=tmpCol;
    end
end

function A=HessenbergHouseholderReflection(A,nss)

    szA=size(A,1);
    e1=zeros(szA-nss,1);
    e1(1,1)=1;

    nssCol=A(nss+1:szA,nss);
    if sign(nssCol(1,1))<0
        signCol=-1;
    else
        signCol=1;
    end
    refl=(signCol*norm(nssCol,2)).*e1+nssCol;
    if norm(refl,2)>0
        refl=(1/norm(refl,2)).*refl;
    end

    A(nss+1:szA,nss:szA)=A(nss+1:szA,nss:szA)-2.*(refl*(refl')*A(nss+1:szA,nss:szA));
    A(1:szA,nss+1:szA)=A(1:szA,nss+1:szA)-2.*(A(1:szA,nss+1:szA)*refl*(refl'));
end
