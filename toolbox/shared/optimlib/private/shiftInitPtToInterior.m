function x0=shiftInitPtToInterior(n,x0,lb,ub,bigInf)

















    feastol=1e-4;
    shift=0.99;

    for i=1:n,
        if lb(i)==ub(i)

            x0(i)=lb(i);
        elseif lb(i)>-bigInf&&ub(i)<bigInf

            if x0(i)<lb(i)+feastol
                if ub(i)-lb(i)<=2
                    mid=(lb(i)+ub(i))/2;
                    x0(i)=mid-0.1*(ub(i)-mid);
                else
                    x0(i)=lb(i)+shift;
                end
            elseif x0(i)>ub(i)-feastol
                if ub(i)-lb(i)<=2
                    mid=(lb(i)+ub(i))/2;
                    x0(i)=mid+0.1*(ub(i)-mid);
                else
                    x0(i)=ub(i)-shift;
                end
            end
        elseif lb(i)>-bigInf

            if x0(i)<lb(i)+feastol
                x0(i)=lb(i)+shift;
            end
        elseif ub(i)<bigInf

            if x0(i)>ub(i)-feastol
                x0(i)=ub(i)-shift;
            end
        end
    end
