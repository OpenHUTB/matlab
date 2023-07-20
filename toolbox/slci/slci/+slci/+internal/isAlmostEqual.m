



function out=isAlmostEqual(expected,actual)
    out=false;

    tol=1e-8;
    [N1,D1]=rat(expected,tol);
    [N2,D2]=rat(actual,tol);
    if N1==N2&&D1==D2
        out=true;
    end
end