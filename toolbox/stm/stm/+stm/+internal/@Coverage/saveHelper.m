



function coverageResults=saveHelper(modelName,harnessName,runInfo,simOut)
    import stm.internal.Coverage;
    coverageResults=[];

    if~exist('simOut','var')




        simOut=[];
    end

    [status,file_name,covObjects]=locGetCovData(simOut,modelName);
    if~status
        return;
    end
    [ownerType,ownerPath]=Coverage.initHarnessCovSettingsHelper(modelName,harnessName);
    [covObjects.testRunInfo]=deal(runInfo);
    coverageResults=Coverage.getMetrics(covObjects,ownerType,ownerPath,file_name);
end

function[status,file_name,covObjects]=locGetCovData(simOut,modelName)
    import stm.internal.Coverage;
    status=false;
    file_name='';
    covObjects=[];





    if isempty(simOut)
        bw=Simulink.data.BaseWorkspace;
        if~bw.exist(Coverage.CovSaveName)

            return;
        end
        covObjects=bw.get(Coverage.CovSaveName);
        covObjects=getAllCovObjects(covObjects);
    else
        if~isprop(simOut,Coverage.CovSaveName)

            return;
        end



        if(~isempty(simOut.sltest_covdata)&&~isempty(simOut.sltest_covdata.fileRef)&&...
            isfield(simOut.sltest_covdata.fileRef,'name')&&~isempty(simOut.sltest_covdata.fileRef.name))
            if slsvTestingHook('STMForceCoverageFailure')
                error STMForceCoverageFailure;
            end
            file_name=simOut.sltest_covdata.fileRef.name;



            covObjects=stm.internal.Coverage.loadCovObjects(simOut.sltest_covdata.fileRef.name,modelName);


            if numel(covObjects)
                file_name='';
            end
        else
            covObjects=simOut.get(Coverage.CovSaveName);
            covObjects=getAllCovObjects(covObjects);
        end
    end
    status=true;
end

function result=getAllCovObjects(covObjects)
    import stm.internal.Coverage;
    if isa(covObjects,'cv.cvdatagroup')
        result=covObjects.getAll;
    else
        result={covObjects};
    end

    result=Coverage.flattenCovObjects(result);
end
