function[xmin,fx]=rfmin(ax,bx,cx,f,tol)



    if nargin<5
        tol=sqrt(eps);
    end


    R=(sqrt(5)-1)/2;
    C=1-R;


    x0=ax;
    x3=cx;


    if abs(cx-bx)>abs(bx-ax)
        x1=bx;
        x2=bx+C*(cx-bx);
    else
        x2=bx;
        x1=bx-C*(bx-ax);
    end



    f1=f(x1);
    f2=f(x2);
    ftol=eps(abs(f1)+abs(f2));

    while abs(x3-x0)>tol*(abs(x1)+abs(x2))
        if abs(f2-f1)<=ftol
            break
        elseif f2<f1

            [x0,x1,x2]=shft3(x1,x2,R*x2+C*x3);
            [f1,f2]=shft2(f2,f(x2));
        else

            [x3,x2,x1]=shft3(x2,x1,R*x1+C*x0);
            [f2,f1]=shft2(f1,f(x1));
        end
    end


    if f1<f2
        xmin=x1;
        fx=f1;
    else
        xmin=x2;
        fx=f2;
    end
end

function[a,b]=shft2(b,c)
    a=b;
    b=c;
end

function[a,b,c]=shft3(b,c,d)
    a=b;
    b=c;
    c=d;
end
