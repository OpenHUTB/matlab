


function[X]=calculateMatchImpedancesShuntSeries(sourceImpedance,loadImpedance)



    RA=real(sourceImpedance);XA=imag(sourceImpedance);
    RL=real(loadImpedance);XL=imag(loadImpedance);

    X1(1)=(RL*XA-(RA*RL*(RA^2-RL*RA+XA^2))^(0.5))/(RA-RL);
    X1(2)=(RL*XA+(RA*RL*(RA^2-RL*RA+XA^2))^(0.5))/(RA-RL);

    X2(1)=-XL-(RA^2*X1(1)+XA^2*X1(1)+XA*X1(1)^2)/(RA^2+(XA+X1(1))^2);
    X2(2)=-XL-(RA^2*X1(2)+XA^2*X1(2)+XA*X1(2)^2)/(RA^2+(XA+X1(2))^2);



    if(X1(1)==Inf||X1(2)==Inf||isnan(X1(1))||isnan(X1(2)))

        [X1,X2]=oneElementMatch(sourceImpedance,loadImpedance);
    end
    X=[X1',X2'];
end