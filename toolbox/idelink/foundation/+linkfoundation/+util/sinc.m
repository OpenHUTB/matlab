function y=sinc(x)




    i=find(x==0);

    x(i)=1;

    y=sin(pi*x)./(pi*x);

    y(i)=1;

