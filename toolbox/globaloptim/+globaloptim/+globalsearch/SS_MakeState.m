function state=SS_MakeState()
















    state.CurrentState='init';
    state.Evaluations=0;
    state.StartTime=cputime;
    state.StopFlag=[];
    state.LastImprovementTime=state.StartTime;
    state.DuplicatesRemoved=0;
    state.DiversityCalls=0;
    state.IntensifyStage=0;
    state.IntensifyEvaluations=0;
    state.NoChangeCounter=0;
    state.BestFval=Inf;
    state.BestPoint=[];
    state.RefSet=struct('points',[],'functionVals',[],'size',0);
    state.Combinations=struct('points',[],'functionVals',[],'size',0);
    state.NumInfeasPoints=0;
    state.MaxPenFeas=[];
    state.PointDbaseSize=0;


    state.ObjRange=[];
    state.ConRange=[];
    state.EqConRange=[];
    state.ObjIQRange=[];
    state.ConIQRange=[];
    state.EqConIQRange=[];


    state.ObjMaxFeas=[];