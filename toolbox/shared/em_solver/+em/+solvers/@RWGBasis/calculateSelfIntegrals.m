function calculateSelfIntegrals(obj)







    P=obj.Mesh.P;
    t=obj.Mesh.t(:,1:3);
    FacesTotal=size(t,1);
    IS=zeros(FacesTotal,1);
    for m=1:FacesTotal
        Vertex=P(t(m,:),:);
        r1=Vertex(1,:)';
        r2=Vertex(2,:)';
        r3=Vertex(3,:)';

        r12=r2-r1;
        r23=r3-r2;
        r13=r3-r1;

        a=sum(r13.*r13);
        b=sum(r13.*r23);
        c=sum(r23.*r23);
        d=a-2*b+c;

        A=sqrt(a);
        B=sqrt(b);
        C=sqrt(c);
        D=sqrt(d);



        N1=(a-b+A*D)*(b+A*C);
        D1=(-a+b+A*D)*(-b+A*C);

        N2=(-b+c+C*D)*(b+A*C);
        D2=(b-c+C*D)*(-b+A*C);

        N3=(a-b+A*D)*(-b+c+C*D);
        D3=(b-c+C*D)*(-a+b+A*D);

        Int=1/6*(1/A*log(N1/D1)+1/C*log(N2/D2)+1/D*log(N3/D3));
        IS(m)=4*Int;
    end
    obj.SelfIntegral=IS;
end
