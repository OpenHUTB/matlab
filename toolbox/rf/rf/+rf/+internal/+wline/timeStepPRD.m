function[prd,jac_stamp,ynew_rhs,ynew]=timeStepPRD(prd,h,unew)
%#codegen



    coder.internal.noRuntimeChecksInThisFunction()













    n=size(prd.Adiag,1);
    if n==0
        jac_stamp=prd.D;
        ynew_rhs=zeros(size(prd.D,1),2);
        if nargin==3
            ynew=jac_stamp*unew+ynew_rhs;
        else
            ynew=zeros(size(ynew_rhs));
        end
    else
        hhalf=h/2;

        hssB=hhalf*prd.B;

        tx=trimult(n,prd.Asub,prd.Adiag,prd.Asuper,prd.xold);
        temp2=prd.xold+hhalf*tx+hssB*prd.uold;

        temp=[hssB,temp2];
        xnew_comb=trisolve(n,-hhalf*prd.Asub,ones(size(prd.Adiag))-hhalf*prd.Adiag,-hhalf*prd.Asuper,temp);



        xnew_rhs=xnew_comb(:,2:3);
        ynew_rhs=prd.C*xnew_rhs;
        jac_stamp=prd.D+prd.C*xnew_comb(:,1);

        if nargin==3
            prd.xnew=xnew_comb(:,1)*unew+xnew_rhs;
            ynew=jac_stamp*unew+ynew_rhs;
        else
            ynew=zeros(size(ynew_rhs));
        end
    end
end

function x=trimult(n,a,b,c,d)
    x=zeros(size(d));
    x(1,:)=b(1)*d(1,:)+c(1)*d(2,:);
    for i=2:n-1
        x(i,:)=a(i-1)*d(i-1,:)+b(i)*d(i,:)+c(i)*d(i+1,:);
    end
    x(n,:)=a(n-1)*d(n-1,:)+b(n)*d(n,:);
end

function x=trisolve(n,a,b,c,d)








    for i=1:n-1
        w=a(i)/b(i);
        if w~=0
            b(i+1)=b(i+1)-w*c(i);
            d(i+1,:)=d(i+1,:)-w*d(i,:);
        end
    end
    x=zeros(size(d));
    x(n,:)=d(n,:)/b(n);
    for i=n-1:-1:1
        x(i,:)=(d(i,:)-c(i)*x(i+1,:))/b(i);
    end

end


