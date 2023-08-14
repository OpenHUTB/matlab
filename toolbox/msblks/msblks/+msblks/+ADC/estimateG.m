function[K,L,gNumeratorAll,gtype]=estimateG(unitCapacitanceStage,gNumerator,tolerance,order,gtype)






    K=[];
    L=[];
    gNumeratorAll=[];
    series=1:4;
    round_error=ones(1,length(series));

    for i=1:length(gNumerator)
        if gtype(i*2-1+rem(order,2))=='T'
            minUnitCapacitance=min([unitCapacitanceStage(i*2+rem(order,2)),...
            unitCapacitanceStage(i*2-1+rem(order,2))]);
            ng=gNumerator(i)*unitCapacitanceStage(i*2-1+rem(order,2))/minUnitCapacitance;
            if abs(ng)>1/3
                ng=gNumerator(i);
                gtype(i*2-1+rem(order,2))='t';
            end
            totalCapacitanceG=(2*series.^2*ng-2*series.*ng+1)./(series*ng);
            roundCapacitanceG=round(totalCapacitanceG);
            parallelCapacitanceG=roundCapacitanceG-2.*series;
            everyG=(1./series)./(parallelCapacitanceG+2);
            if gtype(i*2-1+rem(order,2))=='T'
                everyNewG=everyG.*minUnitCapacitance/unitCapacitanceStage(i*2-1+rem(order,2));
            else
                everyNewG=everyG;
            end
            tempRoundCapacitanceG=roundCapacitanceG;
            for j=1:length(series)
                round_error(j)=abs(gNumerator(i)-everyNewG(j));
                if abs(gNumerator(i)-everyNewG(j))>abs(tolerance*gNumerator(i))
                    roundCapacitanceG(j)=Inf;
                end
            end
            [minTotalGCapacitance,minSeries]=min(roundCapacitanceG);
            if minTotalGCapacitance==Inf
                [minError,minSeries]=min(round_error);
                minTotalGCapacitance=tempRoundCapacitanceG(minSeries);
            end
            minParallel=minTotalGCapacitance-2*minSeries;
            numeratorGAdd=(1/minSeries)/(minParallel+2);
            if gtype(i*2-1+rem(order,2))=='T'
                numeratorGOrder=numeratorGAdd*minUnitCapacitance/unitCapacitanceStage(i*2-1+rem(order,2));
            else
                numeratorGOrder=numeratorGAdd;
            end


            K=[K,minParallel];
            L=[L,minSeries];
            gNumeratorAll=[gNumeratorAll,numeratorGOrder];
        else
            K=[K,0];
            L=[L,0];
            gNumeratorAll=[gNumeratorAll,gNumerator(i)];

        end
    end