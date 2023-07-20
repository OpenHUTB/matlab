function stiffness=EKDAEPartStiffDetermination(A,mu)





    szA=size(A,1);


    if szA==1
        if abs(A)>=1/mu
            stiffness=true;
        else
            stiffness=false;
        end
        return;
    end


    [A,~]=pivotOnce(A);

    if normSpectralRadiusStiffness(A,mu)>=1
        stiffness=true;
    else
        stiffness=false;
    end
end

function[A,rowOrd]=pivotOnce(A)

    szA=size(A,1);
    rowNorms=vecnorm(A);

    [~,pivot]=max(rowNorms);
    rowOrd=1:szA;

    rowOrd(1,1)=pivot;
    rowOrd(1,pivot)=1;
    A=A(:,rowOrd);
    A=A(rowOrd,:);
end

function rho=normSpectralRadiusStiffness(A,mu)


    szA=size(A,1);
    normH22=norm(A(2:szA,2:szA),'fro');
    b=A(2:szA,1);
    H11=1-mu.*A(1,1);
    rhsH=A(1,2:szA)*[b,A(2:szA,2:szA)];
    B12=-(mu/H11).*rhsH;
    x=B12(1,:)';
    rho=abs(mu)*sqrt(normH22*normH22+norm(b,2)*norm(b,2)+norm(x,2)*norm(x,2));
end
