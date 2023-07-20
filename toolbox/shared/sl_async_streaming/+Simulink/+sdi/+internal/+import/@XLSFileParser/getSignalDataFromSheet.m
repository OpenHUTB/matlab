function ret=getSignalDataFromSheet(this,ds,signalIndices,timeIndices,sheetIdx)









    skipCols=[];
    numNonParamSigs=numel(signalIndices);
    SignalData=this.initializeSignalData();
    signalNames={};
    for sigId=1:numel(ds)
        signalNames{end+1}=ds{sigId}.Name;%#ok
    end
    busHier={};
    for sigIdx=1:numel(ds)
        if sigIdx<=numNonParamSigs&&~isempty(find(skipCols==signalIndices(sigIdx),1))


            continue;
        end
        curEl=ds{sigIdx};
        currSigName=curEl.Name;
        SignalData(end+1).isComplex=false;%#ok
        SignalData(end).DataVals=0;
        SignalData(end).TimeVals=0;
        SignalData(end).Element=curEl;


        if isa(curEl,'Simulink.SimulationData.Parameter')
            SignalData(end).LeafName=curEl.Name;
            continue;
        end


        for timeIdx=1:length(timeIndices)
            if signalIndices(sigIdx)>timeIndices(timeIdx)
                SignalData(end).TimeColID=timeIndices(timeIdx);
            end
        end

        busHier={};
        if~isvarname(currSigName)


            if this.isBusSignal(currSigName)
                SignalData(end).isBus=true;

                while(this.isBusSignal(currSigName))
                    [busHier{end+1},currSigName]=...
                    this.getRootBusName(currSigName);%#ok
                end
                SignalData(end).BusHier=busHier;
                leafName=currSigName;
                SignalData(end).LeafName=leafName;
                if this.isComplexSignal(leafName)

                    [SignalData(end),realColIDs,imagColIDs,extractedLeafName_Comp]=...
                    this.extractComplexSignalData(SignalData(end),...
                    signalNames,signalIndices,leafName);
                    skipCols=[skipCols,realColIDs,imagColIDs];%#ok
                    nameParts=SignalData(end).BusHier;
                    nameParts{end+1}=extractedLeafName_Comp;%#ok
                end
                if this.isMultiDimensionalSignal(leafName)
                    [SignalData(end),dimsColIDs]=...
                    this.extractMultiDimensionalSignalData(true,...
                    SignalData(end),signalNames,signalIndices,leafName,timeIndices,ds,sigIdx);
                    skipCols=[skipCols,dimsColIDs];%#ok
                end
                if~this.isComplexSignal(leafName)&&~this.isMultiDimensionalSignal(leafName)
                    SignalData(end).LeafName=leafName;
                    SignalData(end).DimsColIDs(end+1)=signalIndices(sigIdx);
                end
            else
                leafName=currSigName;
                SignalData(end).LeafName=leafName;
                if this.isComplexSignal(leafName)
                    [SignalData(end),realColIDs,imagColIDs,~]=...
                    this.extractComplexSignalData(SignalData(end),...
                    signalNames,signalIndices,leafName);


                    if~isempty(skipCols)&&~isempty(realColIDs)&&~isempty(imagColIDs)
                        realColIDs=reshape(realColIDs,1,[]);
                        imagColIDs=reshape(imagColIDs,1,[]);
                    end
                    skipCols=[skipCols,realColIDs,imagColIDs];%#ok
                end
                if this.isMultiDimensionalSignal(leafName)
                    [SignalData(end),dimsColIDs]=...
                    this.extractMultiDimensionalSignalData(false,...
                    SignalData(end),signalNames,signalIndices,leafName,timeIndices,ds,sigIdx);
                    skipCols=[skipCols,dimsColIDs];%#ok
                end
                if~this.isComplexSignal(leafName)&&...
                    ~this.isMultiDimensionalSignal(leafName)
                    SignalData(end).LeafName=leafName;
                    SignalData(end).DimsColIDs(end+1)=signalIndices(sigIdx);
                end
            end
        else


            SignalData(end).LeafName=currSigName;
            SignalData(end).DimsColIDs(end+1)=signalIndices(sigIdx);
        end
    end
    ret=this.getVarParserForSheet(SignalData,signalNames,...
    signalIndices,busHier,sheetIdx);
end