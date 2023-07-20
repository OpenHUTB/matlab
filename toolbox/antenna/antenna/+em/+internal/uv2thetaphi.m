function[theta,phi]=uv2thetaphi(u1,v1)








    [uval,vval]=meshgrid(u1,v1);
    u=uval(:);
    v=vval(:);
    hypotenuse=hypot(u,v);
    index=find(hypotenuse>1);
    u(index)=[];
    v(index)=[];
    hypotenuse(index)=[];
    phi=(atan2d(v,u));
    theta=(asind(hypotenuse));

end

