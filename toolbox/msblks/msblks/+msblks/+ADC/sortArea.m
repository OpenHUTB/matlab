function[Area,TotalCapacitance]=sortArea(architecture,order,numberLevel,w,l,aNumerator,bNumerator,cNumerator,gNumerator,aDenominator,bDenominator,cDenominator,gType,K,L,unitCpacitance)





    switch architecture
    case 'CIFB'
        aNumeratorNew=aNumerator;
        aDenominatorNew=aDenominator;
        bNumeratorNew=floor(bNumerator(1:(order)))+4*rem(bNumerator(1:(order)),1);
        bDenominatorNew=bDenominator(1:(order));
        cNumeratorNew=[0,floor(cNumerator(1:(order-1)))+4*rem(cNumerator(1:(order-1)),1)];
        cDenominatorNew=[0,cDenominator(1:(order-1))];
        gDenominatorNew=[];
        gNumeratorNew=zeros(1,order);
    case 'CIFF'
        cNumeratorNew=[0,floor(cNumerator(1:(order-1)))+4*rem(cNumerator(1:(order-1)),1)];
        cDenominatorNew=[0,cDenominator(1:(order-1))];
        aNumeratorNew=zeros(1,order);
        aDenominatorNew=ones(1,order);
        bNumeratorNew=floor(bNumerator(1:(order)))+4*rem(bNumerator(1:(order)),1);
        bDenominatorNew=bDenominator(1:order);
        gNumeratorNew=zeros(1,order);
        gDenominatorNew=[];
    case 'CRFB'
        cNumeratorNew=[0,floor(cNumerator(1:(order-1)))+4*rem(cNumerator(1:(order-1)),1)];
        cDenominatorNew=[0,cDenominator(1:(order-1))];
        aNumeratorNew=aNumerator;
        aDenominatorNew=aDenominator;
        bNumeratorNew=floor(bNumerator(1:(order)))+4*rem(bNumerator(1:(order)),1);
        bDenominatorNew=bDenominator(1:order);
        gNumeratorNew=zeros(1,order);
        gDenominatorNew=[];
    case 'CRFF'
        cNumeratorNew=floor(cNumerator)+4*rem(cNumerator,1);
        cDenominatorNew=cDenominator;
        aNumeratorNew=zeros(1,order);
        aDenominatorNew=ones(1,order);
        bNumeratorNew=floor(bNumerator(1:(order)))+4*rem(bNumerator(1:(order)),1);
        bDenominatorNew=bDenominator(1:order);
        gNumeratorNew=zeros(1,order);
        gDenominatorNew=[];
    end
    for i=1:floor(order/2)
        if gType=='N'
            gNumeratorNew(i*2-1+rem(order,2))=gNumerator(i);
        else
            if w(i)==l(i)
                gNumeratorNew(i*2-1+rem(order,2))=K(i)+2*L(i);
            else
                gNumeratorNew(i*2+rem(order,2))=K(i)+2*L(i);
            end
        end
    end

    NumberPerStage=bNumeratorNew+bDenominatorNew+cNumeratorNew+(numberLevel-1)*...
    aNumeratorNew+gNumeratorNew;
    NumberPerStage=2*NumberPerStage;
    AreaPerStage=NumberPerStage.*w.*l;
    CapacitorPerStage=NumberPerStage.*unitCpacitance;
    Area=sum(AreaPerStage);
    Area=Area*1e-6;
    TotalCapacitance=sum(CapacitorPerStage);