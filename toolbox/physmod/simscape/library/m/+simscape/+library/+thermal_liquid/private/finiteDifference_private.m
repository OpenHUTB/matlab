function dFdx=finiteDifference_private(F,x)%#codegen





    coder.allowpcode('plain')

    x=x(:);
    [m,n]=size(F);
    dFdx=zeros(m,n);

    if m==2

        dFdx(1,:)=firstOrderDifference(F(1:2,:),x(1:2));
        dFdx(2,:)=dFdx(1,:);
    else

        dFdx(2:m-1,:)=centralDifference(F,x);

        dFdx(1,:)=firstOrderDifference(F(1:2,:),x(1:2));
        dFdx(m,:)=firstOrderDifference(F(m-1:m,:),x(m-1:m));
    end

end




function dFdx=centralDifference(F,x)

    m=length(x);
    delta_x=diff(x);


    delta_xm=delta_x(1:m-2);
    delta_xp=delta_x(2:m-1);


    cm=-delta_xp./delta_xm./(delta_xm+delta_xp);
    c0=(delta_xp-delta_xm)./(delta_xm.*delta_xp);
    cp=delta_xm./delta_xp./(delta_xm+delta_xp);


    dFdx=bsxfun(@times,cm,F(1:m-2,:))+bsxfun(@times,c0,F(2:m-1,:))+bsxfun(@times,cp,F(3:m,:));

end




function dFdx=firstOrderDifference(F,x)

    dFdx=bsxfun(@rdivide,diff(F),diff(x));

end