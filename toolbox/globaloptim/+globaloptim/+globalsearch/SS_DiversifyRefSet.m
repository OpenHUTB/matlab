function[RefSet,NewIndices,state,Frequencies]=...
    SS_DiversifyRefSet(RefSet,ObjFcn,lb,ub,Nonlcon,options,state,Frequencies,xOrigShape)























    state.IntensifyStage=0;
    state.DiversityCalls=state.DiversityCalls+1;


    ToReplace=false(options.RefSetSize,1);
    ToReplace(ceil(options.DiversityRetention+1):options.RefSetSize)=true;
    ToKeep=~ToReplace;


    [NewSolutions,Frequencies]=...
    globaloptim.globalsearch.SS_CreateSolutionPoints(10*RefSet.size,lb,ub,options,Frequencies);


    RefSet.points=globaloptim.globalsearch.SS_AugmentSolutionSet(RefSet.points(ToKeep,:),options.RefSetSize,NewSolutions,options);


    [NewFvals,NewConVals,NewConEqVals,state]=globaloptim.globalsearch.SS_EvaluateSolutions(...
    ObjFcn,RefSet.points(ToReplace,:),Nonlcon,options,state,xOrigShape);
    if length(NewFvals)<sum(ToReplace)




        indices=find(ToReplace);
        indices=indices((length(NewFvals)+1):end);
        RefSet.functionVals(indices)=[];
        RefSet.points(indices,:)=[];
        RefSet.combinationRecord(indices)=[];
        RefSet.size=size(RefSet.points,1);
        if~isempty(RefSet.conVals)
            RefSet.conVals(indices,:)=[];
        end
        if~isempty(RefSet.conEqVals)
            RefSet.conEqVals(indices,:)=[];
        end
        ToReplace(indices)=[];
    else
        RefSet.functionVals(ToReplace,:)=NewFvals;
        if~isempty(RefSet.conVals)
            RefSet.conVals(ToReplace,:)=NewConVals;
        end
        if~isempty(RefSet.conEqVals)
            RefSet.conEqVals(ToReplace,:)=NewConEqVals;
        end
    end


    RefSet.combinationRecord(ToReplace)=true;


    [RefSet,indices]=globaloptim.globalsearch.SS_SortPoints(RefSet,state);
    ToReplace=ToReplace(indices);
    NewIndices=find(ToReplace);
