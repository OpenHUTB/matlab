function thetaWrap=wrapTo2Pi(theta)
%#codegen
    coder.allowpcode('plain');














%#codegen

    twoPiVal=cast(2*pi,'like',theta);


    pos=(theta>0);


    thetaWrap=mod(theta,twoPiVal);


    thetaWrap((thetaWrap==0)&pos)=twoPiVal;

end
