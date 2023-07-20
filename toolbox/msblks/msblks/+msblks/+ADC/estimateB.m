function[K,L,bNumeratorAll]=estimateB(bNumerator,tolerance,bType)






    K=[];
    L=[];
    bNumeratorAll=[];
    series=1:4;
    roundError=ones(1,length(series));
    for i=1:(length(bNumerator)-1)
        if((bType(i)=='T')&&(bNumerator(i)~=0))
            if bNumerator(i)<0
                sign=-1;
            else
                sign=1;
            end
            series=1:4;
            nb=sign*bNumerator(i);
            totalB=(2*series.^2*nb-2*series.*nb+1)./(series*nb);
            roundTotalB=round(totalB);
            bParallel=roundTotalB-2.*series;
            everyB=(1./series)./(bParallel+2);
            for n=1:length(bParallel)
                if bParallel(n)<=0
                    everyB(n)=Inf;
                end
            end
            everySubB=everyB;
            copyRoundTotalB=roundTotalB;
            for j=1:length(series)
                roundError(j)=abs(bNumerator(i)-everySubB(j));
                if abs(bNumerator(i)-everySubB(j))>abs(tolerance*bNumerator(i))
                    roundTotalB(j)=Inf;
                end
                if copyRoundTotalB(j)-2*j<1
                    copyRoundTotalB(j)=Inf;
                    roundTotalB(j)=Inf;
                end
            end
            [minTotalB,minSeries]=min(roundTotalB);
            if minTotalB==Inf
                [minError,minSeries]=min(roundError);
                minTotalB=copyRoundTotalB(minSeries);
            end
            minParalel=minTotalB-2*minSeries;
            minSeries=sign*minSeries;
            numeratorBAdd=(1/minSeries)/(minParalel+2);
            K=[K,minParalel];
            L=[L,minSeries];
            bNumeratorAll=[bNumeratorAll,numeratorBAdd];
        else
            K=[K,0];
            L=[L,0];
            bNumeratorAll=[bNumeratorAll,bNumerator(i)];
        end
    end