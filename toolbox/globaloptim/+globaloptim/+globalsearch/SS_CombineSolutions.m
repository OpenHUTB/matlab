function[RefSet,Combinations,state]=SS_CombineSolutions(RefSet,SubsetList,lb,ub,options,state)




























    nvars=length(lb);

    NumberOfSubsets=size(SubsetList,1);


    switch lower(options.RefSetType)
    case 'tiered'
        b1=floor(options.GoodFraction.*options.RefSetSize);
    case 'normal'
        b1=options.RefSetSize;
    end

    TotalCombinations=0;

    switch state.IntensifyStage
    case 2

        TotalCombinations=8;
        NumCombinationsToGenerate=2*ones(1,4);
    otherwise




        NumCombinationsToGenerate=zeros(NumberOfSubsets,4);
        for SubsetIndex=1:NumberOfSubsets

            GenCode=(SubsetList(SubsetIndex,1)<=b1)+(SubsetList(SubsetIndex,2)<=b1);
            switch GenCode
            case 2
                TotalCombinations=TotalCombinations+4;
                NumCombinationsToGenerate(SubsetIndex,:)=ones(1,4);
            case 1
                TotalCombinations=TotalCombinations+3;

                NumCombinationsToGenerate(SubsetIndex,[1,4])=1;

                if rand>0.5
                    NumCombinationsToGenerate(SubsetIndex,2)=1;
                else
                    NumCombinationsToGenerate(SubsetIndex,3)=1;
                end
            case 0
                TotalCombinations=TotalCombinations+2;

                if rand>0.5
                    NumCombinationsToGenerate(SubsetIndex,1)=1;
                else
                    NumCombinationsToGenerate(SubsetIndex,4)=1;
                end
                if rand>0.5
                    NumCombinationsToGenerate(SubsetIndex,2)=1;
                else
                    NumCombinationsToGenerate(SubsetIndex,3)=1;
                end
            end
        end
    end


    Combinations=zeros(TotalCombinations,nvars);

    CombinationIndex=1;


    BoundarySubsetIndex=ceil(linspace(1,NumberOfSubsets,ceil(0.5*NumberOfSubsets)));

    for SubsetIndex=1:NumberOfSubsets

        Subset=RefSet.points(SubsetList(SubsetIndex,:),:);

        d=0.5*(Subset(2,:)-Subset(1,:));






        s1ToLB=(Subset(1,:)-lb);
        s1ToLB(s1ToLB<0)=0;
        s1ToUB=(Subset(1,:)-ub);
        s1ToUB(s1ToUB>0)=0;
        s2ToLB=(lb-Subset(2,:));
        s2ToLB(s2ToLB>0)=0;
        s2ToUB=(ub-Subset(2,:));
        s2ToUB(s2ToUB<0)=0;
        boundDist=[s1ToLB;s1ToUB;s2ToLB;s2ToUB];


        m=boundDist./d(ones(4,1),:);

        m(m<0)=Inf;

        m(:,(end+1))=1;
        m=min(m,[],2);

        X1OuterD=min(m(1:2))*d;
        X2OuterD=min(m(3:4))*d;
        if X1OuterD==0
            NumCombinationsToGenerate(SubsetIndex,1)=0;
        end
        if X2OuterD==0
            NumCombinationsToGenerate(SubsetIndex,4)=0;
        end


        if any(SubsetIndex==BoundarySubsetIndex)




            NewCombinations=i_boundarySearchOptim(Subset,lb,ub,d,X2OuterD,'x2');
            Combinations([CombinationIndex,CombinationIndex+1],:)=NewCombinations;



            NewCombinations=i_boundarySearchOptim([Subset(2,:);Subset(1,:)],lb,ub,d,X1OuterD,'x1');
            Combinations([CombinationIndex+2,CombinationIndex+3],:)=NewCombinations;


            CombinationIndex=CombinationIndex+4;

        else

            switch options.CombineMethod
            case 'linear'

                for GenerateNum=1:NumCombinationsToGenerate(SubsetIndex,1)

                    Combinations(CombinationIndex,:)=...
                    Subset(1,:)-rand*X1OuterD;
                    CombinationIndex=CombinationIndex+1;
                end

                for GenerateNum=1:NumCombinationsToGenerate(SubsetIndex,2)

                    Combinations(CombinationIndex,:)=...
                    Subset(1,:)+rand*d;
                    CombinationIndex=CombinationIndex+1;
                end

                for GenerateNum=1:NumCombinationsToGenerate(SubsetIndex,3)

                    Combinations(CombinationIndex,:)=...
                    Subset(2,:)-rand*d;
                    CombinationIndex=CombinationIndex+1;
                end

                for GenerateNum=1:NumCombinationsToGenerate(SubsetIndex,4)

                    Combinations(CombinationIndex,:)=...
                    Subset(2,:)+rand*X2OuterD;
                    CombinationIndex=CombinationIndex+1;
                end
            case 'hypercube'

                for GenerateNum=1:NumCombinationsToGenerate(SubsetIndex,1)

                    Combinations(CombinationIndex,:)=...
                    Subset(1,:)-rand(1,nvars).*X1OuterD;
                    CombinationIndex=CombinationIndex+1;
                end

                for GenerateNum=1:NumCombinationsToGenerate(SubsetIndex,2)

                    Combinations(CombinationIndex,:)=...
                    Subset(1,:)+rand(1,nvars).*d;
                    CombinationIndex=CombinationIndex+1;
                end

                for GenerateNum=1:NumCombinationsToGenerate(SubsetIndex,3)

                    Combinations(CombinationIndex,:)=...
                    Subset(2,:)-rand(1,nvars).*d;
                    CombinationIndex=CombinationIndex+1;
                end

                for GenerateNum=1:NumCombinationsToGenerate(SubsetIndex,4)

                    Combinations(CombinationIndex,:)=...
                    Subset(2,:)+rand(1,nvars).*X2OuterD;
                    CombinationIndex=CombinationIndex+1;
                end
            end
        end
    end


    RefSet.combinationRecord(SubsetList(:))=false;


    Combinations=Combinations(1:(CombinationIndex-1),:);

    NumCombinations=size(Combinations,1);
    if NumCombinations>1

        Combinations=unique(Combinations,'rows');
        if size(Combinations,1)<NumCombinations
            state.DuplicatesRemoved=state.DuplicatesRemoved+NumCombinations-size(Combinations,1);
            NumCombinations=size(Combinations,1);
        end
    end


    Combinations=setdiff(Combinations,RefSet.points,'rows');
    if size(Combinations,1)<NumCombinations
        state.DuplicatesRemoved=state.DuplicatesRemoved+NumCombinations-size(Combinations,1);
        NumCombinations=size(Combinations,1);
    end



    PointsToAddToDbase=options.MaxPointDatabaseSize-state.PointDbaseSize;
    if PointsToAddToDbase<NumCombinations
        Combinations=Combinations(1:PointsToAddToDbase,:);
        NumCombinations=PointsToAddToDbase;
    end


    Combinations=struct('size',NumCombinations,...
    'points',Combinations,...
    'functionVals',Inf(NumCombinations,1),...
    'maxPerViol',zeros(NumCombinations,1));
    state.Combinations=Combinations;

    function NewCombinations=i_boundarySearchOptim(Subset,lb,ub,d,XOuterD,dir)


        TOL=1e-4;


        x1=Subset(1,:);
        x2=Subset(2,:);


        R=ub-lb;


        du=ub-x2;


        dl=lb-x2;


        A=x2-x1;


        nVar=length(x1);
        NewCombinations=zeros(2,nVar);

        if any(abs(du)<TOL*R|abs(dl)<TOL*R)





            if strcmpi(dir,'x2')
                dirFac=1;
            else
                dirFac=-1;
            end


            NewCombinations(1,:)=x2-dirFac*rand(1,nVar).*d;


            NewCombinations(2,:)=x2+dirFac*rand(1,nVar).*XOuterD;

        else


            tu=du./A;
            tl=dl./A;
            t=[tu,tl];
            maxt=min(t(t>=0));
            NewCombinations(1,:)=Subset(2,:)+maxt*A;
            NewCombinations(2,:)=Subset(2,:)+0.5*maxt*A;
        end
