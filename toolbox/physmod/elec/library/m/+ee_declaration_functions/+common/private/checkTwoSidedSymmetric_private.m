function flag=checkTwoSidedSymmetric_private(x)%#codegen




    coder.allowpcode('plain');

    n=length(x);

    flag=0;

    if rem(n/2,1)==0
        flag=1;
    elseif x((n+1)/2)~=0
        flag=2;
    else
        for i=1:(n+1)/2
            if-x(i)~=x(n-i+1)
                flag=3;
            end
        end
    end

end