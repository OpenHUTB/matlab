function[numeratorA,numeratorB,numeratorC,numeratorG,denominatorA,denominatorB,denominatorC,denominatorG,estimateA,estimateB,estimateC,estimateG,bform,gform]=estimateCoefficient(a,b,c,g,order,architecture,~,numberLevel,Vref)












    architectureLast=upper(architecture(3:4));


    switch architectureLast
    case 'FB'
        stageA=a./((numberLevel-1)*Vref);
        stageC=[0;c(1:(order-1))];
        stageB=b;
        QuantStage=[c(order),stageB(order+1)];
        stageB=stageB(1:order);
    case 'FF'
        stageC=c;
        stageC(1)=stageC(1)./((numberLevel-1)*Vref);
        stageA=zeros(1,order);
        stageB=b;
        QuantStage=[stageB(order+1);a];
        stageB=stageB(1:order);
    end
    if(rem(order,2))
        indexG=1;
    else
        indexG=0;
    end
    stageG=zeros(1,order);
    for i=1:(floor(order/2))
        stageG(i*2-1+indexG)=g(i);
    end
    tmpStageA=[];
    tmpStageB=[];
    tmpStageC=[];
    tmpStageG=[];
    tmpD=[];
    gform=[];
    bform=[];

    for i=1:order

        ratioSpread=max([abs(stageA(i)),abs(stageB(i)),abs(stageC(i)),abs(stageG(i))])/...
        min(nonzeros([abs(stageA(i)),abs(stageB(i)),abs(stageC(i)),3*abs(stageG(i))]));
        accuracyEstimation=2*ceil(ratioSpread);
        toleranceStage=0.03;
        [stageANew,stageBNew,stageCNew,stageGNew,valueD,bformTemp,gformTemp]=estimateStage(stageA(i),stageB(i),stageC(i),stageG(i),toleranceStage);
        tmpStageA=[tmpStageA,stageANew];
        tmpStageB=[tmpStageB,stageBNew];
        tmpStageC=[tmpStageC,stageCNew];
        tmpStageG=[tmpStageG,stageGNew];
        tmpD=[tmpD,valueD];
        gform=[gform,gformTemp];
        bform=[bform,bformTemp];
    end

    [numeratorQuad,denominatorQuad]=estimateQuadStage(QuantStage);

    switch architectureLast
    case 'FB'
        numeratorA=tmpStageA;
        denominatorA=tmpD;
        numeratorB=[tmpStageB,numeratorQuad(2)];
        denominatorB=[tmpD,denominatorQuad(2)];
        numeratorC=[tmpStageC(2:(order)),numeratorQuad(1)];
        denominatorC=[tmpD(2:(order)),denominatorQuad(1)];
    case 'FF'
        numeratorA=numeratorQuad(2:(order+1));
        denominatorA=denominatorQuad(2:(order+1));
        numeratorB=[tmpStageB,numeratorQuad(1)];
        denominatorB=[tmpD,denominatorQuad(1)];
        numeratorC=tmpStageC;
        denominatorC=tmpD;

    end

    if(rem(order,2))
        indexG=1;
    else
        indexG=0;
    end

    numeratorG=[];
    denominatorG=[];
    for i=1:(floor(order/2))
        numeratorG=[numeratorG,tmpStageG(i*2-1+indexG)];
        denominatorG=[denominatorG,tmpD(i*2-1+indexG)];
    end

    if strcmp(architectureLast,'FB')
        estimateA=numeratorA./denominatorA*(numberLevel-1)*Vref;
        estimateC=numeratorC./denominatorC;
    else
        estimateA=numeratorA./denominatorA;
        estimateC=numeratorC./denominatorC;
        estimateC(1)=estimateC(1)*(numberLevel-1)*Vref;
    end
    estimateB=numeratorB./denominatorB;
    estimateG=numeratorG./denominatorG;

    function[numeratorA,numeratorB,numeratorC,numeratorG,D,bform,gform]=estimateStage(a,b,c,g,tolerance)


        signA=sign(a);
        signB=sign(b);
        signC=sign(c);
        signG=sign(g);
        a=signA*a;
        b=signB*b;
        c=signC*c;
        g=signG*g;

        break_loop=0;
        editD=0;
        while break_loop==0
            editD=editD+1;
            editA=round(a*editD);
            if abs(b*editD)<1/3
                bform='T';
            else
                bform='N';
            end
            editB=round(2*b*editD)/2;
            editC=round(2*c*editD)/2;
            editG=round(g*editD);
            if abs(g*editD)<1/3
                gform='T';
            else
                gform='N';
            end
            checkA=(abs(editA/editD-a)<=abs(tolerance*a));
            checkB=((bform=='T')||((bform=='N')&&(abs(editB/editD-b)<=abs(tolerance*b))));
            checkC=(abs(editC/editD-c)<=abs(tolerance*c));
            checkG=((gform=='T')||((gform=='N')&&(abs(editG/editD-g)<=abs(tolerance*g))));
            if(checkA&&checkB&&checkC&&checkG)
                break_loop=1;
            end
        end

        numeratorA=signA*editA;
        if bform=='T'
            numeratorB=signB*b*editD;
        else
            numeratorB=signB*editB;
        end
        numeratorC=signC*editC;
        if gform=='T'
            numeratorG=signG*g*editD;
        else
            numeratorG=signG*editG;
        end
        D=editD;

        if numeratorB==0
            bform='N';
        end
        if numeratorG==0
            gform='N';
        end


        function[N,D]=estimateQuadStage(QS)

            ratioSpread=max(QS)/...
            min(nonzeros(QS));
            accuracyEstimation=2*ceil(ratioSpread);
            toleranceStage=min(0.03,1/accuracyEstimation);
            max_spread=200;
            for i=1:max_spread
                editD=i*ones(1,length(QS));
                editN=round(QS.*editD);
                if abs(editN./editD-QS)<=toleranceStage*QS
                    break;
                end
            end
            N=editN;
            D=editD;
