function in=isPointInPolygon(pt,x,y)
    n=numel(x);
    x=[x,x(1)];
    y=[y,y(1)];
    w=zeros(1,n);
    for ix=1:n
        vp=[x(ix)-pt(1),y(ix)-pt(2)];
        vn=[x(ix+1)-pt(1),y(ix+1)-pt(2)];
        ang=acos(fastdot(vp,vn)/(norm(vp)*norm(vn)));
        if perpdot(vn,vp)<0
            ang=-ang;
        end
        w(ix)=ang;
    end
    w=sum(w);
    in=round(w/(2*pi))~=0;

    function d=perpdot(v1,v2)
        d=fastdot([v1(2),-v1(1)],v2);

        function c=fastdot(a,b)
            c=sum(conj(a).*b);