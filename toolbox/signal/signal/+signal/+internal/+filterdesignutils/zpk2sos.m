function[num,den]=zpk2sos(z,p,k)







%#codegen

    coder.inline('never');
    coder.allowpcode('plain');

    narginchk(2,3);
    if nargin<3
        k=1;
    end

    z=sort4roots(z(:));
    p=sort4roots(p(:));

    cast1=cast(1,class(z));
    sqrtk=sqrt(abs(k));
    B1=[cast1,-z(1)-z(2),z(1)*z(2)]*sqrtk*sign(k);
    B2=[cast1,-z(3)-z(4),z(3)*z(4)]*sqrtk;
    A1=[cast1,-p(1)-p(2),p(1)*p(2)];
    A2=[cast1,-p(3)-p(4),p(3)*p(4)];
    num=real([B1;B2]);
    den=real([A1;A2]);


    function p=sort4roots(inp)





        p=complex(inp);


        [~,idx]=sort(abs(imag(p)));
        p=p(idx);




        paa=abs(angle(p));
        DT=class(p);
        if abs(paa(1)-paa(4))<=eps(DT)||abs(paa(2)-paa(3))<=eps(DT)
            p([1,3])=p([3,1]);
        end





        if p(1)==p(2)&&p(3)==p(4)
            p(:)=p([1,3,2,4]);
        end
