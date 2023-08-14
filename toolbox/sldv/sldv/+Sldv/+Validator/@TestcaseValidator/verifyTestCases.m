
function[objWithValidationStatus,simOut,covData]=verifyTestCases(obj,simData,objectives)




    objWithValidationStatus={};

    [covData,runtestError,simOut]=obj.getCoverageFromTestCases(simData);


    for tcIdx=1:length(objectives)
        objWithValidationStatus{tcIdx}=[];%#ok<AGROW>
        extraArgs={};
        if~isempty(obj.testComp)&&~runtestError&&~isempty(covData{tcIdx})&&isa(simOut{tcIdx},'Simulink.SimulationOutput')
            if SlCov.CovMode.isXIL(obj.simMode)
                extraArgs={'codeCovReader',sldv.code.xil.internal.CovDataReader(covData{tcIdx})};
            else
                extraArgs={'codeCovReader',sldv.code.internal.CustomCodeCovDataReader(covData{tcIdx})};
            end
        end

        cov_objectives=objectives{tcIdx};

        for i=1:length(cov_objectives)
            objIdx=cov_objectives(i);
            objStatus=struct('objective',[],'status',[]);
            objStatus.objective=objIdx;
            if runtestError||~isa(simOut{tcIdx},'Simulink.SimulationOutput')


                objStatus.status=Sldv.Validator.ValidationStatus.RuntimeError;
                objWithValidationStatus{tcIdx}=[objWithValidationStatus{tcIdx},objStatus];
            elseif~runtestError&&strcmp(obj.sldvData.Objectives(objIdx).type,'Execution')
                objStatus.status=Sldv.Validator.ValidationStatus.Success;
                objWithValidationStatus{tcIdx}=[objWithValidationStatus{tcIdx},objStatus];
            elseif~runtestError&&isempty(covData{tcIdx})
                objStatus.status=Sldv.Validator.ValidationStatus.NoCoverage;
                objWithValidationStatus{tcIdx}=[objWithValidationStatus{tcIdx},objStatus];
            elseif obj.ignoreObjectiveForValidation(objIdx)

                objStatus.status=Sldv.Validator.ValidationStatus.IgnoredDueToBlockReplacement;
                objWithValidationStatus{tcIdx}=[objWithValidationStatus{tcIdx},objStatus];
            else
                switch obj.sldvData.Objectives(objIdx).type
                case{'Decision','Condition','MCDC','RelationalBoundary','Test objective',...
                    'S-Function Decision','S-Function Condition','S-Function MCDC',...
                    'S-Function RelationalBoundary','S-Function Entry','S-Function Exit',...
                    'Requirements Table Objective'}
                    objStatus.status=Sldv.Validator.ValidationStatus.Inconclusive;
                    try
                        [isCovered,~,noCoverage,isUnvalidated]=obj.validateObjective(obj.objectiveToGoalMap(objIdx),covData{tcIdx},extraArgs{:});
                        if noCoverage
                            objStatus.status=Sldv.Validator.ValidationStatus.NoCoverage;
                        elseif isUnvalidated
                            objStatus.status=Sldv.Validator.ValidationStatus.Unvalidated;
                        elseif isCovered
                            objStatus.status=Sldv.Validator.ValidationStatus.Success;
                        else
                            objStatus.status=Sldv.Validator.ValidationStatus.NotSuccess;
                        end
                    catch Mex %#ok<NASGU>
                        objStatus=Sldv.Validator.ValidationStatus.Inconclusive;
                    end
                    objWithValidationStatus{tcIdx}=[objWithValidationStatus{tcIdx},objStatus];
                otherwise
                    objStatus.status=Sldv.Validator.ValidationStatus.Ignored;
                    objWithValidationStatus{tcIdx}=[objWithValidationStatus{tcIdx},objStatus];
                end
            end
        end
    end
end


