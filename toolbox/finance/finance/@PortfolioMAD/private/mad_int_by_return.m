function[pwgt,status]=mad_int_by_return(obj,ProbStruct,retn)














    solver=obj.solverMINLP;
    hasExtraVars=true;
    nAssets=ProbStruct.NumAssets;


    c=zeros(numel(ProbStruct.LB),1);
    c(end)=1;


    linearRiskCoef=[];



    Aretn=[-ProbStruct.RetnLin;0]';
    bretn=-retn+ProbStruct.RetnScalar;



    fminconOptions=getFminconOptions(obj);
    Y=obj.localScenarioHandle([],[]);
    sampleAssetMean=obj.sampleAssetMean;
    dY=bsxfun(@minus,Y,sampleAssetMean(:)');

    nonLinObj=@(x)mad_local_objective(x,dY,solver.ObjectiveScalingFactor);
    NLPfcnHandle=@(intVar,x0)fmincon(nonLinObj,x0,...
    [ProbStruct.AIn(:,1:end-1);Aretn(:,1:end-1)],[ProbStruct.bIn;bretn],...
    ProbStruct.AEq(:,1:end-1),ProbStruct.bEq,...
    [ProbStruct.LB(1:end-1-nAssets);intVar],[ProbStruct.UB(1:end-1-nAssets);intVar],...
    [],fminconOptions);

    [pwgt,~,status]=solver.solve(ProbStruct.CutsOfNonLinFcn,ProbStruct.NumAssets,c,...
    [ProbStruct.AIn;Aretn],[ProbStruct.bIn;bretn],...
    ProbStruct.AEq,ProbStruct.bEq,ProbStruct.LB,ProbStruct.UB,...
    hasExtraVars,[],...
    ProbStruct.IntVarIndx,NLPfcnHandle,linearRiskCoef);

    if status==0
        warning(message('finance:internal:finance:PortfolioMixedInteger:int_by_return:UnconvergedByRetnProblem'));
    end

    if status<0
        error(message('finance:internal:finance:PortfolioMixedInteger:int_by_return:InfeasibleByRetnProblem'));
    end
    pwgt=pwgt(1:nAssets,:);
end
