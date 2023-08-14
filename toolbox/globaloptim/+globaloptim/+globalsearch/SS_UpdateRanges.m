function state=SS_UpdateRanges(state,PointDbase)

















    TOL=1e-4;


    state.ObjRange=[min(PointDbase.functionVals);max(PointDbase.functionVals)];
    state.ConRange=[min(PointDbase.conVals,[],1);max(PointDbase.conVals,[],1)];
    state.EqConRange=[min(PointDbase.conEqVals,[],1);max(PointDbase.conEqVals,[],1)];
    state.ObjIQRange=globaloptim.globalsearch.SS_IqRange(PointDbase.functionVals);
    state.ConIQRange=globaloptim.globalsearch.SS_IqRange(PointDbase.conVals);
    state.EqConIQRange=globaloptim.globalsearch.SS_IqRange(PointDbase.conEqVals);


    isFeas=all([PointDbase.conVals,abs(PointDbase.conEqVals)]<=TOL,2);
    state.ObjMaxFeas=max(PointDbase.functionVals(isFeas));