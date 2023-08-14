function[PointSet,idx,sortedScore]=SS_SortPoints(PointSet,state)


















    Score=globaloptim.globalsearch.SS_CalculateScore(PointSet.points,PointSet.functionVals,...
    PointSet.conVals,PointSet.conEqVals,state);


    [sortedScore,idx]=sort(Score);


    PointSet.points=PointSet.points(idx,:);
    PointSet.functionVals=PointSet.functionVals(idx);
    if~isempty(PointSet.conVals)
        PointSet.conVals=PointSet.conVals(idx,:);
    end
    if~isempty(PointSet.conEqVals)
        PointSet.conEqVals=PointSet.conEqVals(idx,:);
    end



    if ismember('combinationRecord',fieldnames(PointSet))
        PointSet.combinationRecord=PointSet.combinationRecord(idx);
    end


