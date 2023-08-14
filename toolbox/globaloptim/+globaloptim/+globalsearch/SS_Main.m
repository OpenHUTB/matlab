function[TrialSolutions,NumFunEvals]=SS_Main(ObjFcn,x0,lb,ub,Nonlcon,options)



















    xOrigShape=x0;


    lb=lb(:)';
    ub=ub(:)';
    x0=x0(:)';


    options.UsePointDatabase='on';





    state=globaloptim.globalsearch.SS_MakeState;


    globaloptim.globalsearch.SS_CheckStopCriteria(options,state);


    [RefSet,Frequencies]=globaloptim.globalsearch.SS_SelectInitialSet(x0,lb,ub,options);
    RefSet.combinationRecord=true(options.RefSetSize,1);
    state.RefSet=RefSet;


    state.CurrentState='iter';


    [RefSet.functionVals,RefSet.conVals,RefSet.conEqVals,state]=...
    globaloptim.globalsearch.SS_EvaluateSolutions(ObjFcn,RefSet.points,Nonlcon,options,...
    state,xOrigShape);


    if length(RefSet.functionVals)<RefSet.size
        RefSet.size=length(RefSet.functionVals);
        RefSet.points=RefSet.points(1:RefSet.size,:);
    end


    if strcmpi(options.UsePointDatabase,'on')
        PointDbase=struct(...
        'size',0,...
        'points',[],...
        'functionVals',[],...
        'conVals',[],...
        'conEqVals',[]);
        [PointDbase,state]=i_addPointsToDatabase(PointDbase,...
        RefSet,1:RefSet.size,state);
    end


    state.NumPoints=numel(RefSet.functionVals);


    RefSet=globaloptim.globalsearch.SS_SortPoints(RefSet,state);
    state.RefSet=RefSet;


    exitFlag=globaloptim.globalsearch.SS_CheckStopCriteria(options,state);


    while isempty(exitFlag)



        if state.IntensifyStage~=2&&~any(RefSet.combinationRecord)
            if options.DiversityRetention==options.RefSetSize
                state.StopFlag=sprintf(['No new combinations remain, and options.DiversityRetention\n                                          '...
                ,'prevents the Diversify method from producing new ones.']);
            else


                [RefSet,NewIndices,state,Frequencies]=...
                globaloptim.globalsearch.SS_DiversifyRefSet(RefSet,ObjFcn,lb,ub,Nonlcon,...
                options,state,Frequencies,xOrigShape);

                if strcmpi(options.UsePointDatabase,'on')

                    [PointDbase,state]=i_addPointsToDatabase(...
                    PointDbase,RefSet,NewIndices,state);
                end
            end
        end


        SubsetList=globaloptim.globalsearch.SS_GenerateSubsets(RefSet,state);


        [RefSet,Combinations,state]=globaloptim.globalsearch.SS_CombineSolutions(RefSet,...
        SubsetList,lb,ub,options,state);


        [Combinations.functionVals,Combinations.conVals,...
        Combinations.conEqVals,state]=...
        globaloptim.globalsearch.SS_EvaluateSolutions(ObjFcn,Combinations.points,Nonlcon,...
        options,state,xOrigShape);


        if strcmpi(options.UsePointDatabase,'on')
            [PointDbase,state]=i_addPointsToDatabase(...
            PointDbase,Combinations,1:Combinations.size,state);
        end


        RefSet=globaloptim.globalsearch.SS_UpdateReferenceSet(RefSet,Combinations,options,state);
        state.RefSet=RefSet;


        state.NumPoints=state.NumPoints+size(Combinations.points,1);


        exitFlag=globaloptim.globalsearch.SS_CheckStopCriteria(options,state);

    end





    TrialSolutions=PointDbase.points';


    NumFunEvals=state.Evaluations;


    function[PointDbase,state]=i_addPointsToDatabase(PointDbase,NewSet,idx,state)
        PointDbase.points=[PointDbase.points;NewSet.points(idx,:)];
        PointDbase.functionVals=[PointDbase.functionVals;NewSet.functionVals(idx,:)];
        if~isempty(NewSet.conVals)
            PointDbase.conVals=[PointDbase.conVals;NewSet.conVals(idx,:)];
        end
        if~isempty(NewSet.conEqVals)
            PointDbase.conEqVals=[PointDbase.conEqVals;NewSet.conEqVals(idx,:)];
        end
        PointDbase.size=PointDbase.size+length(idx);


        state.PointDbaseSize=PointDbase.size;


        state=globaloptim.globalsearch.SS_UpdateRanges(state,PointDbase);
