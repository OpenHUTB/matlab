function thetaUnwrapped=angunwrap(theta)
%#codegen
    coder.allowpcode('plain');











%#codegen



    uprBndCrs=(theta>0.5*pi)*(theta<-0.5*pi);
    lwrBndCrs=(theta<-0.5*pi)*(theta>0.5*pi);

    numOf2Pi=floor((angunwrap(theta)+pi-1e-6)/(2*pi))...
    +(uprBndCrs-lwrBndCrs);





    thetaUnwrapped=theta+numOf2Pi*2*pi;
end