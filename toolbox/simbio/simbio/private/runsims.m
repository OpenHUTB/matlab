function simDataCell=runsims(phiCell,modelObj,compiledModelMap,doseObjects,timeVec,groupID,fitData,useParallel)














    transaction=SimBiology.Transaction.create(modelObj);%#ok<NASGU>            




    StatesToLog=modelObj.getconfigset('active').RuntimeOptions.StatesToLog;


    configset=modelObj.getconfigset('active');
    configset.StopTime=0;
    configset.SolverOptions.LogSolverAndOutputTimes=1;
    missingObservedStates=setdiff(compiledModelMap.Observed,StatesToLog);
    compiledModelMap.Observed=[StatesToLog;missingObservedStates];


    regressionFcn=sbiomakeregressionfcn(modelObj,compiledModelMap,doseObjects,fitData,useParallel);

    nPhi=numel(phiCell);
    nGroups=max(groupID);
    simDataCell=cell(nPhi);
    for j=1:nPhi




        tmpCell={};
        tmpCell{1}(nGroups)=SimData;
        simDataCell{j}=tmpCell{1};

        simDataCell{j}(nGroups)=SimData;




        phi=phiCell{j}';



        if size(phi,1)==1&&nGroups>1
            phi=repmat(phi,nGroups,1);
        end


        [~,~,simDataCell{j}]=regressionFcn(phi,timeVec,(1:nGroups)');
    end
end