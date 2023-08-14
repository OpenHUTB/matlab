function SetToAugment=SS_AugmentSolutionSet(SetToAugment,FinalSetSize,PointSet,options)



















    PointSetSize=size(PointSet,1);
    if~isempty(SetToAugment)
        NumberOfInputSolutions=size(SetToAugment,1);
    else
        NumberOfInputSolutions=0;
    end
    NumberToAdd=FinalSetSize-NumberOfInputSolutions;
    nvars=size(PointSet,2);


    if NumberToAdd<=0
        return
    end


    if NumberOfInputSolutions==0
        Index=ceil(rand*PointSetSize);
        SetToAugment(1,:)=PointSet(Index,:);
        PointSet(Index,:)=[];
        PointSetSize=PointSetSize-1;
        NumberOfInputSolutions=1;
    end


    SetToAugment((NumberOfInputSolutions+1):FinalSetSize,:)=zeros(NumberToAdd,nvars);


    for SolutionIndex=(NumberOfInputSolutions+1):FinalSetSize

        DistanceList=options.DistanceMeasureFcn(SetToAugment,SolutionIndex-1,PointSet,PointSetSize);

        [tmp,MaxIndex]=max(DistanceList);
        SetToAugment(SolutionIndex,:)=PointSet(MaxIndex,:);

        PointSet(MaxIndex,:)=[];
        PointSetSize=PointSetSize-1;
    end