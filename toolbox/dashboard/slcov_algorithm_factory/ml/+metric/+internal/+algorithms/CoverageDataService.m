classdef CoverageDataService<metric.DataService




    properties(Constant)
        CoverageKeys={'decision',cvmetric.Structural.block,'condition','mcdc'};
    end

    methods
        function obj=CoverageDataService()
            obj.AlgorithmID='CoverageDataService';
            obj.Version=1;
        end
        function resources=collectData(this,scopeUuid,queryResult)

            resources=metric.internal.algorithms.CoverageDataServiceResource(...
            this.ID,scopeUuid);
            seqs=queryResult.getSequences();







            if isempty(seqs)||isempty(seqs{1})
                return;
            end





            modelNames=cellfun(@(x)string(x{1}.Label),seqs);
            seq1=seqs{1};
            if numel(seq1)==1
                return;
            end
            as_results=seq1(2:2:end);
            as_resultSets=seq1(3:2:end);



            hasTopLevelTestResult=false;
            for i=1:numel(as_results)
                resultUuid=as_results{i}.Address;
                resultId=stm.internal.getResultFromUUID(resultUuid);
                result=sltest.testmanager.TestResult.getResultFromID(resultId);
                metaData=result.SimulationMetadata;
                if isempty(metaData)

                    allIterationResults=result.getIterationResults;
                    for j=1:numel(allIterationResults)
                        iterationResult=allIterationResults(j);
                        md=iterationResult.SimulationMetadata();
                        if~isempty(md)
                            if isempty(metaData)
                                metaData=iterationResult.SimulationMetadata();
                            else
                                metaData(end+1)=iterationResult.SimulationMetadata();%#ok<AGROW> 
                            end
                        end
                    end
                end
                for j=1:numel(metaData)
                    if isempty(metaData(j).harness)
                        if strcmp(modelNames(1),metaData(j).modelName)
                            hasTopLevelTestResult=true;
                        end
                    else
                        if strcmp(modelNames(1),metaData(j).harnessOwner)
                            hasTopLevelTestResult=true;
                        end
                    end
                end
            end
            if~hasTopLevelTestResult
                if strcmp(this.ID,'CoverageDataServiceRequirements')

                else
                    this.notifyUserError(message('dashboard:algorithms:NoTopLevelTestResult',...
                    modelNames(1)));
                    resources.CoverageFragment=[];
                    return;
                end
            end





            resultUuidStruct=struct('ResultSetUuid',{},'TestCaseResultUuid',{});
            for k=1:numel(as_results)
                tcResultId=stm.internal.getResultFromUUID(as_results{k}.Address);
                if tcResultId~=0
                    tcResult=sltest.testmanager.TestResult.getResultFromID(tcResultId);
                    if tcResult.NumTotalIterations>0

                        for itResult=tcResult.getIterationResults
                            itResultUuid=itResult.ResultUUID;
                            resultUuidStruct(end+1).TestCaseResultUuid=itResultUuid;%#ok<AGROW> 
                            resultUuidStruct(end).ResultSetUuid=as_resultSets{k}.Address;
                        end
                    else

                        resultUuidStruct(end+1).TestCaseResultUuid=as_results{k}.Address;%#ok<AGROW> 
                        resultUuidStruct(end).ResultSetUuid=as_resultSets{k}.Address;
                    end
                else
                    resultUuidStruct(end+1).TestCaseResultUuid=as_results{k}.Address;%#ok<AGROW> 
                    resultUuidStruct(end).ResultSetUuid=as_resultSets{k}.Address;
                end
            end




            cfragment=[];
            try
                cfragment=stm.internal.Coverage.getMergedCoverage(...
                modelNames,resultUuidStruct);

            catch ME



                if ME.identifier~=message('stm:CoverageStrings:MergeCoverageError').Identifier
                    rethrow(ME);
                end
            end

            if isempty(cfragment)||isempty(cfragment(1).CoverageData)


                this.notifyUserWarning(message('dashboard:algorithms:NoModelCoverage',...
                modelNames(1)));
            else
                hasMergedTestCaseResults=false(numel(resultUuidStruct),1);
                for i=1:numel(resultUuidStruct)
                    rsUuid_1=resultUuidStruct(i).ResultSetUuid;
                    tcrUuid_1=resultUuidStruct(i).TestCaseResultUuid;
                    for j=1:numel(cfragment)
                        mergedTestCaseResults=cfragment(j).MergedTestCaseResults;
                        for k=1:numel(mergedTestCaseResults)
                            rsUuid_2=mergedTestCaseResults(k).ResultSetUuid;
                            tcrUuid_2=mergedTestCaseResults(k).TestCaseResultUuid;
                            if strcmp(rsUuid_1,rsUuid_2)&&strcmp(tcrUuid_1,tcrUuid_2)
                                hasMergedTestCaseResults(i)=true;
                            end
                        end
                    end
                end
                if nnz(hasMergedTestCaseResults)~=numel(resultUuidStruct)
                    this.notifyUserWarning(message(...
                    'dashboard:algorithms:CoverageMergeConflict',...
                    nnz(hasMergedTestCaseResults),numel(resultUuidStruct),modelNames(1)));
                end
            end

            resources.CoverageFragment=cfragment;
        end
    end
end
