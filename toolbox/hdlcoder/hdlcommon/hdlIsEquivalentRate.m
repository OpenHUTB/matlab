function e=hdlIsEquivalentRate(r1,r2)

    if r1==r2

        e=true;
    elseif r1*r2<=0

        e=false;
    else


        [n,d]=rat(r1/r2);
        e=n==d;
    end

end
