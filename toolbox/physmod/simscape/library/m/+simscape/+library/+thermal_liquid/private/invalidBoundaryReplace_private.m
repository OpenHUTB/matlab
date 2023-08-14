function F=invalidBoundaryReplace_private(F,x,y,x_min,x_max,y_min,y_max,validity)%#codegen















    coder.allowpcode('plain')

    x=x(:);
    y=y(:)';
    [m,n]=size(F);


    validity=bsxfun(@and,bsxfun(@and,validity,(x>=x_min)&(x<=x_max)),(y>=y_min)&(y<=y_max));


    F=fillrows(F,y,validity,m,n);


    validity=~isnan(F);
    if any(~validity(:))
        F=fillrows(F',x,validity',n,m)';
    end

end




function F=fillrows(F,y,validity,m,n)

    for i=1:m

        valid=validity(i,:);


        if all(~valid)
            F(i,:)=NaN(1,n);
            continue
        end


        [~,jFirst]=max(valid);
        [~,jLast]=max(flip(valid));
        jLast=n-jLast+1;


        for j=1:jFirst-1
            F(i,j)=extrap(F(i,jFirst),F(i,jFirst+1),y(jFirst),y(jFirst+1),y(j));
        end
        for j=jLast+1:n
            F(i,j)=extrap(F(i,jLast-1),F(i,jLast),y(jLast-1),y(jLast),y(j));
        end
    end

end




function Fe=extrap(F1,F2,x1,x2,xe)

    Fe=(F2-F1)/(x2-x1)*(xe-x1)+F1;

end