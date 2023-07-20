function T=torque_private(dFdX,I)%#codegen














    coder.allowpcode('plain');


    if~isempty(find(I<0,1))
        two_sided=true;
    else
        two_sided=false;
    end

    [ni,nx]=size(dFdX);
    T=zeros(ni,nx);
    for j=1:nx

        dFdX_col=dFdX(:,j);

        if two_sided==false

            T(:,j)=cumtrapz(I,dFdX(:,j))';

        else

            idx_p=find(I>0,1);
            idx_n=find(I<0,1,'last');


            [I_n,idx_sort]=sort(-I(1:idx_n+1));


            T(idx_sort,j)=cumtrapz(I_n,-dFdX_col(idx_sort)')';


            T(idx_p-1:end,j)=cumtrapz(I(idx_p-1:end),dFdX_col(idx_p-1:end)')';

        end
    end

end