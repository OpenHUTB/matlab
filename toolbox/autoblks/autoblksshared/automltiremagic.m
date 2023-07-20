function y=automltiremagic(D,C,B,E,u)%#codegen
    coder.allowpcode('plain')




    y=D.*sin(C.*atan(B.*u-E.*(B.*u-atan(B.*u))));
end