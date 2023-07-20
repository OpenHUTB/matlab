function performLazyImport(varargin)

    repo=sdi.Repository(1);
    sigIDs=[];

    if isempty(varargin)
        wksParser=Simulink.sdi.internal.import.WorkspaceParser.getDefault();
        numSigs=wksParser.LazyImportParsers.getCount();
        if numSigs>0
            wksParser.LazyImportRunIDs.Clear();
            sigIDs=zeros([numSigs,1],'int32');
            for idx=1:numSigs
                sigIDs(idx)=wksParser.LazyImportParsers.getKeyByIndex(idx);
            end
            str=getString(message('SDI:sdi:ImportingProgress'));
            progTracker=Simulink.sdi.ProgressTracker(str,numSigs,true);
        end
    else
        sigIDs=varargin{1};
        progTracker=[];

    end


    for idx=1:length(sigIDs)
        locLazyImport(repo,sigIDs(idx),progTracker);
    end

end


function locLazyImport(repo,sigID,progTracker)
    wksParser=Simulink.sdi.internal.import.WorkspaceParser.getDefault();
    if wksParser.LazyImportParsers.isKey(sigID)
        varParser=wksParser.LazyImportParsers.getDataByKey(sigID);
        wksParser.LazyImportParsers.deleteDataByKey(sigID);
        try
            dataVals.Time=double(getTimeValues(varParser));
            dataVals.Data=getDataValues(varParser);
            repo.setSignalDataValues(sigID,dataVals);
        catch me %#ok<NASGU>

        end
    end
    if~isempty(progTracker)
        incrementValue(progTracker);
    end
end
