function A=areaOfPolygon(p)



    pm=[p;p(1,:)]';


    Np=size(pm,2);
    A=0;
    for i=1:Np-1
        A=A+(det([pm(1:2,i),pm(1:2,i+1)]));
    end

    A=abs(A)/2;