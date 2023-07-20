function y=distvec(x1,x2)

    x2=x2';
    y=sqrt(sum((x1-x2).^2));


