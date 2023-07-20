function ret=export(this,runIDs,signalIDs,~,eng,~,opts,bCmdLine)



    sw=warning('off','MATLAB:xlswrite:AddSheet');
    tmp=onCleanup(@()warning(sw));


    if isfield(opts,'shareTimeColumn')
        if~opts.shareTimeColumn
            opts.shareTimeColumn='off';
        elseif strcmp(opts.shareTimeColumn,'off')
            opts.shareTimeColumn='off';
        else
            opts.shareTimeColumn='on';
        end
    end
    opts=this.getDefaultExportOptions(opts);




    this.RateBasedGrouping=true;
    if strcmp(opts.shareTimeColumn,'off')
        this.RateBasedGrouping=false;
    end



    leafSigIDs=int32.empty;
    processedSigs=int32.empty;
    if~bCmdLine
        for sigIdx=1:length(signalIDs)
            [leafSigIDs,processedSigs]=locRecGetAllLeafSigIDs(signalIDs(sigIdx),leafSigIDs,processedSigs,eng.sigRepository);
        end
    else
        leafSigIDs=signalIDs;
    end
    numSelectedRuns=length(runIDs);
    numSigs=length(leafSigIDs);
    bFullRun=true([1,numSelectedRuns]);
    ret=safeTransaction(eng,@locExportToExcel,this,eng,bFullRun,numSigs,opts,runIDs,leafSigIDs,bCmdLine);
end


function[leafIDs,processedSigs]=locRecGetAllLeafSigIDs(sigID,leafIDs,processedSigs,repo)

    if~isempty(find(processedSigs==sigID,1))
        return
    end
    processedSigs(end+1)=sigID;


    childIDs=repo.getSignalChildren(sigID);
    if isempty(childIDs)

        info=repo.getSignalComplexityAndLeafPath(sigID);
        if~info.IsImagPart
            leafIDs(end+1)=sigID;
        end
    else
        for idx=1:numel(childIDs)
            [leafIDs,processedSigs]=locRecGetAllLeafSigIDs(childIDs(idx),leafIDs,processedSigs,repo);
        end
    end
end


function ret=locExportToExcel(this,eng,bFullRun,numSigs,opts,runIDs,sigIDs,bCmdLine)
    ret=this.exportToExcel(eng,bFullRun,numSigs,opts,runIDs,sigIDs,bCmdLine);
end
