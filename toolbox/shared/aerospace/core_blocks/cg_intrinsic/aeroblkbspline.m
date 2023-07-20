
function output=aeroblkbspline(p,m,V,i,u)
%#codegen


    coder.allowpcode('plain');
    coder.license('checkout','Aerospace_Toolbox');
    coder.license('checkout','Aerospace_Blockset');


    N=zeros(p+2,1);


    if((i==1)&&(u==V(1)))
        output=1.0;
        return;
    end

    if((i==(m-p))&&(u==V(m+1)))
        output=1.0;
        return;
    end
    if((u<V(i))||(u>=V(i+p+1)))
        output=0.0;
        return;
    end
    for j=1:p+1
        if((u>=V(i+j-1))&&(u<V(i+j)))
            N(j)=1.0;
        else
            N(j)=0.0;
        end
    end

    for k=1:p
        if(N(1)==0.0)
            saved=0.0;
        else
            saved=((u-V(i))*N(1))/(V(i+k)-V(i));
        end

        for j=1:(p-k)+1
            Vleft=V(i+j);
            Vright=V(i+j+k);
            if(N(j+1)==0.0)
                N(j)=saved;
                saved=0.0;
            else
                temp=N(j+1)/(Vright-Vleft);
                N(j)=saved+(Vright-u)*temp;
                saved=(u-Vleft)*temp;
            end
        end
    end
    output=N(1);
end
