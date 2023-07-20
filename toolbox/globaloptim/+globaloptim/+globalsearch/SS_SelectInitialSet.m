function[RefSet,Frequencies]=SS_SelectInitialSet(X0,lb,ub,options)






















    nvars=length(lb);
    range=ub-lb;


    stratRandFlag=strcmp(options.InitialSetMethod,'stratRand');
    if stratRandFlag
        Frequencies=ones(nvars,4);
    else
        Frequencies=[];
    end


    RefSet=struct('size',options.RefSetSize,...
    'points',zeros(options.RefSetSize,nvars),...
    'functionVals',Inf(options.RefSetSize,1),...
    'conVals',[],...
    'conEqVals',[],...
    'combinationRecord',logical(triu(ones(options.RefSetSize),1)));



    InitialRefSet(1,:)=lb;
    InitialRefSet(2,:)=ub;
    InitialRefSet(3,:)=lb+range/2;



    if all(X0>=lb&X0<=ub)&&any(X0~=lb)&&any(X0~=ub)&&...
        any(X0~=lb+range/2)
        InitialRefSet(4,:)=X0;
        NumberOfUserPoints=1;
    else
        NumberOfUserPoints=0;
    end



    CandSetSize=options.RefSetSize*10;
    if stratRandFlag
        [InitialSet,Frequencies]=...
        globaloptim.globalsearch.SS_CreateSolutionPoints(CandSetSize,lb,ub,options,Frequencies);
    else
        InitialSet=globaloptim.globalsearch.SS_CreateSolutionPoints(CandSetSize,lb,ub,options);
    end


    RefSet.points(1:NumberOfUserPoints+3,:)=InitialRefSet;


    RefSet.points=globaloptim.globalsearch.SS_AugmentSolutionSet(RefSet.points(1:NumberOfUserPoints+3,:),...
    RefSet.size,InitialSet,options);