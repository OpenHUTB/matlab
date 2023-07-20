function data=getExportDataForStreamout(mdl,domain,fmt,logIntervals,runID)



    if nargin<4
        logIntervals=[];
    end

    if nargin<5
        runID=0;
    end


    repo=sdi.Repository(1);
    if~runID
        Simulink.HMI.synchronouslyFlushWorkerQueue(repo);
    end


    data=repo.safeTransaction(@locGetExportData,mdl,domain,fmt,logIntervals,repo,runID);
end


function data=locGetExportData(mdl,domain,fmt,logIntervals,repo,runID)

    bMultiInput=iscell(domain);
    if bMultiInput
        data=cell(size(domain));
    else
        data=cell(1,1);
        domain={domain};
        fmt={fmt};
    end


    if~runID
        runID=repo.getCurrentStreamingRunID(mdl);
    end

    if~runID
        return
    end


    domainSigIDs=[];
    numEl=numel(domain);
    for idx=1:numEl

        if strcmpi(fmt{idx},'array')&&locIntervalsNotSet(logIntervals)
            if isempty(domainSigIDs)
                domainSigIDs=getSignalIDsForDomain(repo,runID,domain);
            end
            sigIDs=domainSigIDs{idx};
            if numel(sigIDs)==1&&~repo.getSignalIsVarDims(sigIDs)
                [data{idx},bTranspose]=repo.getSignalDataValuesNoTime(sigIDs);
                if bTranspose
                    data{idx}=data{idx}.';
                end
                continue
            end
        end


        dsr=Simulink.sdi.DatasetRef(runID,domain{idx});
        dsr.setIntervalsAndOverride(logIntervals,[]);


        data{idx}=dsr.fullExport();
        sigIDs=dsr.getSortedSignalIDs();
        data{idx}=Simulink.sdi.internal.convertToFormat(data{idx},fmt{idx},sigIDs);
    end


    if~bMultiInput
        data=data{1};
    end
end


function ret=locIntervalsNotSet(logIntervals)

    ret=true;


    if isempty(logIntervals)
        return
    end


    if ischar(logIntervals)
        logIntervals=evalin('base',logIntervals);
    end


    if~isempty(logIntervals)
        ret=~any(isfinite(logIntervals));
    end
end
