function qout=exp(q)%#codegen






    validateattributes(q,{'numeric'},{'ncols',4,'real','finite','nonnan'})


    th=vecnorm(q(:,2:4),2,2);


    qout=exp(q(:,1)).*[cos(th),sin(th).*q(:,2:4)./th];


    if any(th==0)
        qout(th==0,2:4)=0;
    end
end