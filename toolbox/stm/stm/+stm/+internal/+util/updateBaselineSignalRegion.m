
function hasNonDefaultSync=updateBaselineSignalRegion(baselineFile,compareToSignalId,leftTimePt,rightTimePt,sheet,range)

    hasNonDefaultSync=false;

    if exist(baselineFile,'file')~=2
        error(message('stm:BaselineCriteria:BaselineFileNotExists',baselineFile));
    end

    [~,fileName,ext]=fileparts(baselineFile);
    if strcmpi(ext,'.mat')
        baselineRunId=Simulink.sdi.createRun('baselineRun','file',baselineFile);
    elseif any(xls.internal.WriteTable.SpreadsheetExts.contains(ext,'IgnoreCase',true))

        sheetsFromFile=sheetnames(baselineFile);
        if~any(strcmp(sheetsFromFile,sheet))
            error(message('stm:BaselineCriteria:BaselineSheetNotExist',sheet,[fileName,ext]));
        end


        if~isempty(range)
            range=strsplit(range,':');
            range=range{1};
        end


        T=xls.internal.ReadTable(baselineFile,'Sheet',sheet,'Range',string(range));
        ds=T.readMetadata(xls.internal.SourceTypes.Output);
        baselineRunId=Simulink.sdi.createRun('baselineRun','vars',ds);
    else
        error(message('stm:BaselineCriteria:CannotUpdateNonMatExcelBaseline'));
    end

    if(isempty(baselineRunId))
        error(message('stm:BaselineCriteria:BaselineFileNotContainSignal',baselineFile));
    end

    if(leftTimePt>rightTimePt)
        [leftTimePt,rightTimePt]=deal(rightTimePt,leftTimePt);
    end

    engine=Simulink.sdi.Instance.engine;

    baselineRun=Simulink.sdi.getRun(baselineRunId);
    parentSignalId=engine.getSignalParent(compareToSignalId);


    diff=Simulink.sdi.getDiffSignalResultByComparisonSignalID(engine.sigRepository,parentSignalId);
    simOutSignal=Simulink.sdi.getSignal(diff.sigID2);

    c=onCleanup(@()resetToInitialState(baselineRunId));

    algorithms=[Simulink.sdi.AlignType.BlockPath
    Simulink.sdi.AlignType.SID
    Simulink.sdi.AlignType.SignalName];
    EXPAND_MATRICES=true;


    Simulink.sdi.doAlignment(engine.sigRepository,simOutSignal.RunID,baselineRunId,int32(algorithms),EXPAND_MATRICES);
    matchedBaselineSignalId=Simulink.sdi.getAlignedID(simOutSignal.ID);

    if isempty(matchedBaselineSignalId)
        error(message('stm:BaselineCriteria:CurrentSignalNotExistingInBaseline',baselineFile));
    end

    matchedBaselineSignal=baselineRun.getSignal(matchedBaselineSignalId);
    bslnSigDataValues=matchedBaselineSignal.Values.Data;
    indicesToReplace=(matchedBaselineSignal.Values.Time>=leftTimePt&...
    matchedBaselineSignal.Values.Time<=rightTimePt);
    timeValuesToReplace=matchedBaselineSignal.Values.Time(indicesToReplace);

    if length(simOutSignal.Values.Time)==1
        [dataValuesToReplace(1:length(timeValuesToReplace))]=deal(simOutSignal.DataValues.Data);
        if isStringScalar(dataValuesToReplace)

            syncCmpSig=timeseries(dataValuesToReplace,'name',matchedBaselineSignal.Values.name);
            syncCmpSig.Time=timeValuesToReplace;
        else
            syncCmpSig=timeseries(dataValuesToReplace(:),timeValuesToReplace);
        end
    else
        syncCmpSig=getsampleusingtime(simOutSignal.Values,leftTimePt,rightTimePt);

        if~isa(simOutSignal.Values.Data(1),'embedded.fi')

            syncCmpSig=getsampleusingtime(simOutSignal.Values,leftTimePt,rightTimePt);

            if~isstring(bslnSigDataValues(1))



                syncCmpSig=resample(timeseries(syncCmpSig.Data,...
                syncCmpSig.Time),timeValuesToReplace);



                if strcmp(matchedBaselineSignal.Complexity,'complex')&&~isreal(bslnSigDataValues(1))


                    imagBslnVals=imag(bslnSigDataValues(indicesToReplace));




                    syncCmpSig.Data=complex(real(syncCmpSig.Data),imagBslnVals);
                end
            end
        end
    end


    [leftTS,rightTS]=deal(timeseries);
    timeVector=matchedBaselineSignal.Values.Time;


    if any(timeVector<leftTimePt)

        leftTS=getsampleusingtime(matchedBaselineSignal.Values,...
        timeVector(1),timeVector(find(timeVector==leftTimePt)-1));
    end


    if any(timeVector>rightTimePt)

        rightTS=getsampleusingtime(matchedBaselineSignal.Values,...
        timeVector(find(timeVector==rightTimePt)+1),timeVector(end));
    end
    newTS=append(leftTS,syncCmpSig,rightTS);


    matchedBaselineSignal.Values=newTS;

    if strcmpi(ext,'.mat')
        splitNames=strsplit(matchedBaselineSignal.RootSource,'.');
        if~isempty(splitNames)
            varName=splitNames{1};
        else
            varName='data';
        end

        rData=engine.getRunData(baselineRunId);
        dataToSave=rData.get(1);
        eval([varName,'= dataToSave;']);
        save(baselineFile,varName);
    else

        ds=Simulink.sdi.exportRun(baselineRunId);
        wt=xls.internal.WriteTable(ds,'filename',baselineFile,...
        'sheet',sheet,'range',string(range),...
        'SourceType',xls.internal.SourceTypes.Output,...
        'PreserveTolerance',true);
        wt.write;
        hasNonDefaultSync=wt.hasIntscnSync;
    end
end

function resetToInitialState(baselineRunId)
    stm.internal.SignalComparison.removeSDIRuns(baselineRunId);
end