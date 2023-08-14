






function[netsOut,valuesOut]=simplifyNets(netsIn,valuesIn,centerFrequency,combineOppositeImpedances)


    netsOut=zeros(size(netsIn));valuesOut=netsOut;
    traversedIndices=ones(length(netsIn(:,1)),1);
    for k=1:length(netsIn(:,1))
        skip=0;
        for m=1:length(netsIn(1,:))-1
            if(skip)
                skip=0;
                continue;
            end
            comp=netsIn(k,m);
            netsOut(k,traversedIndices(k))=comp;


            if(combineOppositeImpedances&&(netsIn(k,m)<=2&&netsIn(k,m+1)<=2))
                z1=calcImpedance(netsIn(k,m),valuesIn(k,m),centerFrequency);
                z2=calcImpedance(netsIn(k,m+1),valuesIn(k,m+1),centerFrequency);
                z3=z1+z2;
                [c,v]=calcComponent(z3/1j,centerFrequency);
                if(c=='C')
                    netsOut(k,traversedIndices(k))=1;
                else
                    netsOut(k,traversedIndices(k))=2;
                end
                valuesOut(k,traversedIndices(k))=v;
                skip=1;

            elseif(combineOppositeImpedances&&(netsIn(k,m)>=3&&netsIn(k,m+1)>=3))
                z1=calcImpedance(netsIn(k,m),valuesIn(k,m),centerFrequency);
                z2=calcImpedance(netsIn(k,m+1),valuesIn(k,m+1),centerFrequency);
                z3=1/(1/z1+1/z2);
                [c,v]=calcComponent(z3/1j,centerFrequency);
                if(c=='C')
                    netsOut(k,traversedIndices(k))=3;
                else
                    netsOut(k,traversedIndices(k))=4;
                end
                valuesOut(k,traversedIndices(k))=v;
                skip=1;


            elseif(netsIn(k,m)==netsIn(k,m+1))
                if(netsIn(k,m)==1||netsIn(k,m)==4)
                    valuesOut(k,traversedIndices(k))=1/(1/valuesIn(k,m)+1/valuesIn(k,m+1));
                else
                    valuesOut(k,traversedIndices(k))=valuesIn(k,m)+valuesIn(k,m+1);
                end
                skip=1;
            else
                valuesOut(k,traversedIndices)=valuesIn(k,m);
            end
            traversedIndices(k)=traversedIndices(k)+1;
        end
        netsOut(k,traversedIndices(k))=netsIn(k,end);
        valuesOut(k,traversedIndices(k))=valuesIn(k,end);
    end

    k=length(netsOut(1,:));
    while(all(netsOut(:,k)==0))
        netsOut(:,k)=[];
        valuesOut(:,k)=[];
        k=k-1;
    end
end
