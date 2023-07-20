function[maxel,minel,growthRate]=calcMeshParamsCore(obj,lambda,Aboard,Alayer,k)


    if Aboard>=0.9*lambda^2
        N=36;
    else
        N=64;
    end
    maxel=sqrt(4*Aboard/(sqrt(3)*N));





    N=Alayer./(lambda^2);
    frac=10;
    minel=max(sqrt((4.*Alayer)./(frac*N*100*sqrt(3))));

    feedWidth=cylinder2strip(obj.FeedDiameter/2);

    if minel>maxel
        minel=k*maxel;
    elseif minel<feedWidth
        minel=2*feedWidth;
    end


    growthRate=1+mean(Alayer./Aboard);

    if growthRate>1.95
        growthRate=1.95;
    elseif growthRate<1.05
        growthRate=1.05;
    end


    precision=1e2;
    growthRate=round(growthRate*precision)./precision;

end

