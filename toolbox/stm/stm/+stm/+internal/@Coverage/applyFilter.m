


function applyFilter(rs,newFilterFiles)
    rs=stm.internal.Coverage.getResultSetObj(rs);
    newFilterFiles=string(newFilterFiles);
    validateExtension(newFilterFiles);

    removeOldFilterFiles(rs,newFilterFiles);

    [filenames,topModels,crIDs]=stm.internal.getCoverageResults(rs.getResultID,'');
    filenames=string(filenames);
    oc_folderCleanup=onCleanup(@()folderCleanup(filenames(filenames.strlength>0)));
    oc_updateUI=onCleanup(@()stm.internal.updateCoverageResults([],crIDs(1),'UpdateUI'));


    covWarningId='stm:CoverageStrings:ModelModifiedError';
    warnOrigState=warning('query',covWarningId);
    oc_warning=onCleanup(@()warning(warnOrigState.state,covWarningId));
    warning('off',covWarningId);

    applyFailedIdxs=zeros(size(filenames),'logical');
    for idx=1:length(filenames)
        [covObject,isValidCvResult]=stm.internal.Coverage.filenamesToCvDataArray(filenames(idx),topModels(idx));
        if~isValidCvResult


            try
                covResult=stm.internal.getTestManagerCoverageResults(crIDs(idx));
                SlCov.CoverageAPI.deleteModelcov(covResult.AnalyzedModel);
                [covObject,isValidCvResult]=stm.internal.Coverage.filenamesToCvDataArray(filenames(idx),topModels(idx));
            catch
                isValidCvResult=false;
            end

            if~isValidCvResult




                applyFailedIdxs(idx)=true;
                continue;
            end
        end


        covObject.filter=newFilterFiles;
        stm.internal.Coverage.getNewCovMetricsAndUpdateDB(crIDs(idx),covObject);
    end

    if any(applyFailedIdxs)



        failedTopModels=topModels(applyFailedIdxs);
        error(stm.internal.Coverage.getCovErrorMsg(failedTopModels{1},'ApplyFilterToIncompatibleCvdataError'));
    end
end

function validateExtension(files)
    if any(~files.endsWith('.cvf','IgnoreCase',true))
        error(message('stm:CoverageStrings:CoverageFilterFileNameInvalid'));
    end
end

function removeOldFilterFiles(rs,new)
    toRemove=setdiff(rs.FilterFiles,new);
    stm.internal.removeCoverageFilter(rs.getID,toRemove);
end


function folderCleanup(filenames)
    arrayfun(@(file)rmdir(fileparts(file),'s'),filenames);
end