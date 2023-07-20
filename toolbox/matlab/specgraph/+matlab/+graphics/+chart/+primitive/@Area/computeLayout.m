function computeLayout(hObjs)










    [x,y,map]=matlab.graphics.chart.primitive.internal.collectSeriesData(hObjs);



    nonFiniteY=~isfinite(y);

    if any(nonFiniteY(:))

        y(nonFiniteY)=0;
        map(nonFiniteY)=NaN;








        n=size(y,2);
        startNonFinite=any([false(1,n);~nonFiniteY(1:end-1,:)&nonFiniteY(2:end,:)],2);
        closeNonFinite=any([nonFiniteY(1:end-1,:)&~nonFiniteY(2:end,:);false(1,n)],2);





        leftInds=find(startNonFinite)-1;
        rightInds=find(closeNonFinite)+1;


        xLeft=x(leftInds);
        xRight=x(rightInds);


        yLeft=y(leftInds,:);
        yRight=y(rightInds,:);


        yLeft(nonFiniteY(startNonFinite,:))=0;
        yRight(nonFiniteY(closeNonFinite,:))=0;


        mapLeft=map(leftInds,:);
        mapRight=map(rightInds,:);
        mapLeft(nonFiniteY(startNonFinite,:))=NaN;
        mapRight(nonFiniteY(closeNonFinite,:))=NaN;



        someFiniteYData=~all(nonFiniteY,2);
        if~isempty(someFiniteYData)


            someFiniteYData([1,end])=true;
        end
        x=x(someFiniteYData);
        y=y(someFiniteYData,:);
        map=map(someFiniteYData,:);




        x=[xRight;x;xLeft];
        y=[yRight;y;yLeft];
        map=[mapRight;map;mapLeft];


        [x,order]=sort(x);
        y=y(order,:);
        map=map(order,:);
    end


    yTop=cumsum(y,2);
    yBottom=[zeros(numel(x),1),yTop(:,1:end-1)];


    for a=1:numel(hObjs)
        areaLayoutData.XData=x;
        areaLayoutData.YData=[yBottom(:,a),yTop(:,a)];
        areaLayoutData.Order=map(:,a);
        hObjs(a).AreaLayoutData=areaLayoutData;


        hObjs(a).BaseArea=(a==1);
    end

end
