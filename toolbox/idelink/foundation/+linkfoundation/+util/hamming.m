function w=hamming(n)




    if~rem(n,2),

        m=n/2;
        w=(0.54-0.46*cos(2*pi*(0:m-1)'/(n-1)));
        w=[w;w(end:-1:1)];
    else

        m=(n+1)/2;
        w=(0.54-0.46*cos(2*pi*(0:m-1)'/(n-1)));
        w=[w;w(end-1:-1:1)];
    end


