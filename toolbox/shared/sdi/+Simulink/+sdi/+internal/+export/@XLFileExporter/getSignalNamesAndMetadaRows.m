function[namesRow,mdRows]=getSignalNamesAndMetadaRows(this,eng,runObj,sigIDs,...
    dtRow,unitsRow,interpRow,bpathRow,portRow)



    numSigs=length(sigIDs);
    namesRow={this.TimeColName};

    mdRows=struct();
    if~isempty(dtRow)
        mdRows.dataTypeRow=dtRow;
    end
    if~isempty(unitsRow)
        mdRows.unitsRow=unitsRow;
    end
    if~isempty(interpRow)
        mdRows.interpRow=interpRow;
    end
    if~isempty(bpathRow)
        mdRows.blockPathRow=bpathRow;
    end
    if~isempty(portRow)
        mdRows.portIndexRow=portRow;
    end

    sigs=cell(1,length(sigIDs));
    repo=sdi.Repository(1);
    for sigIdx=1:length(sigIDs)
        sigs{sigIdx}=Simulink.sdi.Signal(repo,sigIDs(sigIdx));
    end

    firstSig=sigs{1};
    [namesRow,mdRows]=this.populateMetaDataRows(eng,firstSig,namesRow,mdRows);
    ts=this.getValuesForSignal(firstSig);
    currTimeVals=ts.Time;
    if(this.RateBasedGrouping)
        for sigIdx=2:numSigs
            sig=sigs{sigIdx};
            ts=this.getValuesForSignal(sig);
            sigTimeVals=ts.Time;
            if isequal(currTimeVals,sigTimeVals)
                [namesRow,mdRows]=this.populateMetaDataRows(eng,sig,namesRow,mdRows);
            else
                currTimeVals=sigTimeVals;
                namesRow{end+1}=this.TimeColName;%#ok
                mdRows=this.omitMetadataForTimeCol(mdRows);
                [namesRow,mdRows]=this.populateMetaDataRows(eng,sig,namesRow,mdRows);
            end
        end
    else
        for sigIdx=2:numSigs
            namesRow{end+1}=this.TimeColName;%#ok
            mdRows=this.omitMetadataForTimeCol(mdRows);
            sig=runObj.getSignal(sigIDs(sigIdx));
            [namesRow,mdRows]=this.populateMetaDataRows(eng,sig,namesRow,mdRows);
        end
    end
end
