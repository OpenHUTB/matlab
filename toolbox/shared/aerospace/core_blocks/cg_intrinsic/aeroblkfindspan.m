
function output=aeroblkfindspan(n,p,u,V)

%#codegen


    coder.allowpcode('plain');
    coder.license('checkout','Aerospace_Toolbox');
    coder.license('checkout','Aerospace_Blockset');

    if(u>=V(n+1))
        output=n;
        return;
    end

    low=p;
    high=n+1;
    mid=floor((low+high)/2);

    while((u<V(mid))||(u>=V(mid+1)))
        if(u<V(mid))
            high=mid;
        else
            low=mid;
        end
        mid=floor((low+high)/2);
    end

    output=mid;
end
