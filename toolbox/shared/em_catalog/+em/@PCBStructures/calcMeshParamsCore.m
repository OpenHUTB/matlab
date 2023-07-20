function[maxel,minel,growthRate]=calcMeshParamsCore(obj,lambda)



    Aboard=area(obj.BoardShape);





    N=1;
    k1=8;




    maxel=sqrt(4*lambda/(sqrt(3)*200));




    Alayers=cellfun(@(x)area(x),obj.MetalLayers);

    N=Alayers./(lambda^2);
    frac=10;
    minel=max(sqrt((4.*Alayers)./(frac*N*100*sqrt(3))));


    if strcmpi(obj.FeedViaModel,'strip')
        feedWidth=cylinder2strip(obj.FeedDiameter/2);
    else
        feedWidth=obj.FeedDiameter/2;
    end

    if minel>maxel
        minel=0.75*maxel;
    elseif minel<feedWidth
        minel=2*feedWidth;
    end
    setMeshMinContourEdgeLength(obj,minel);


    growthRate=1+mean(Alayers./Aboard);

    if growthRate>1.95
        growthRate=1.95;
    elseif growthRate<1.05
        growthRate=1.05;
    end


    precision=1e2;
    growthRate=round(growthRate*precision)./precision;


end

