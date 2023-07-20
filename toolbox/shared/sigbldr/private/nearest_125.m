function out=nearest_125(x)





    decade=ceil(log10(x));
    m=x/(10^decade);

    if m<0.2
        m=0.2;
    elseif m<0.5
        m=0.5;
    else
        m=1;
    end

    out=eval(sprintf('%ge%d',m,decade));