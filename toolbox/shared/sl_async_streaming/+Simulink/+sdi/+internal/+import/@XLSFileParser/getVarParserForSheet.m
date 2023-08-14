function dataSet=getVarParserForSheet(this,sigData,sNames,sIndices,busHier,sheetIdx)








    dataSet=Simulink.SimulationData.Dataset();
    busBlockPaths={};
    signalNamesFromFile={};
    for sigIdx=1:length(sigData)
        curSig=sigData(sigIdx);
        currSigDataCols=curSig.DimsColIDs;
        for colIdx=1:length(currSigDataCols)
            colID=currSigDataCols(colIdx);
            sigName=sNames{find(sIndices==colID,1)};
            isSigComplex=this.isComplexSignal(sigName);
            isSigMultiDimensional=this.isMultiDimensionalSignal(sigName);
            if this.isBusSignal(sigName)
                while(this.isBusSignal(sigName))
                    [busHier{end+1},sigName]=...
                    this.getRootBusName(sigName);%#ok
                end
                if this.isComplexSignal(sigName)&&~this.isMultiDimensionalSignal(sigName)
                    if this.isRealPart(sigName)
                        sigData(sigIdx).RealColIDs(end+1)=colID;
                    elseif this.isImagPart(sigName)
                        sigData(sigIdx).ImagColIDs(end+1)=colID;
                    end
                end
                if~this.isComplexSignal(sigName)&&this.isMultiDimensionalSignal(sigName)
                    if isempty(find(sigData(sigIdx).RealColIDs==colID,1))
                        sigData(sigIdx).RealColIDs(end+1)=colID;
                    end
                end
                if this.isComplexSignal(sigName)&&this.isMultiDimensionalSignal(sigName)
                    if this.isRealPart(sigName)
                        if isempty(find(sigData(sigIdx).RealColIDs==colID,1))
                            sigData(sigIdx).RealColIDs(end+1)=colID;
                        end
                    elseif this.isImagPart(sigName)
                        if isempty(find(sigData(sigIdx).ImagColIDs==colID,1))
                            sigData(sigIdx).ImagColIDs(end+1)=colID;
                        end
                    end
                end
                if~this.isComplexSignal(sigName)&&~this.isMultiDimensionalSignal(sigName)
                    if isempty(find(sigData(sigIdx).RealColIDs==colID,1))
                        sigData(sigIdx).RealColIDs(end+1)=colID;
                    end
                end
            else

                if isSigComplex&&~isSigMultiDimensional
                    if this.isRealPart(sigName)
                        sigData(sigIdx).RealColIDs(end+1)=colID;
                    elseif this.isImagPart(sigName)
                        sigData(sigIdx).ImagColIDs(end+1)=colID;
                    end
                end
                if isSigMultiDimensional&&~isSigComplex
                    if isempty(find(sigData(sigIdx).RealColIDs==colID,1))
                        sigData(sigIdx).RealColIDs(end+1)=colID;
                    end
                end
                if isSigMultiDimensional&&isSigComplex
                    if this.isRealPart(sigName)
                        if isempty(find(sigData(sigIdx).RealColIDs==colID,1))
                            sigData(sigIdx).RealColIDs(end+1)=colID;
                        end
                    elseif this.isImagPart(sigName)
                        if isempty(find(sigData(sigIdx).ImagColIDs==colID,1))
                            sigData(sigIdx).ImagColIDs(end+1)=colID;
                        end
                    end
                end
                if~isSigMultiDimensional&&~isSigComplex
                    if isempty(find(sigData(sigIdx).RealColIDs==colID,1))
                        sigData(sigIdx).RealColIDs(end+1)=colID;
                    end
                end
            end
            if isSigMultiDimensional




                if colIdx==length(currSigDataCols)
                    sigData(sigIdx).DataVals=ones(sigData(sigIdx).Dims);
                    curSig.DataVals=ones(sigData(sigIdx).Dims);
                end
            else
                sigData(sigIdx).Dims=max(...
                length(sigData(sigIdx).RealColIDs),...
                length(sigData(sigIdx).ImagColIDs));
                sigData(sigIdx).DataVals=ones(sigData(sigIdx).Dims);
            end
        end
        if curSig.isBus

            nameParts=curSig.BusHier;
            nameParts{end+1}=curSig.LeafName;%#ok
            if curSig.Element.BlockPath.getLength()
                busBlockPaths{end+1}=curSig.Element.BlockPath;%#ok
                hasBlockPath=true;
            else
                busBlockPaths{end+1}=Simulink.SimulationData.BlockPath;%#ok
                hasBlockPath=false;
            end
            rootBusName=nameParts{1};
            signalNameFromFile=strjoin(nameParts,'.');
            isLeafNameRepeated=any(contains(signalNamesFromFile,...
            signalNameFromFile));
            signalNamesFromFile{end+1}=signalNameFromFile;%#ok
            nameParts=nameParts(2:end);
            fullSignalName=strjoin(nameParts,'.');
            if isempty(dataSet.getElement(rootBusName))||isLeafNameRepeated

                sigBus=curSig.Element;
                sigBus.Values=struct();
            else


                ds=dataSet.getElement(rootBusName);
                if isa(ds,'Simulink.SimulationData.Dataset')
                    sigBus=ds{end};
                elseif isa(ds,'Simulink.SimulationData.Signal')
                    sigBus=ds;
                end



                if hasBlockPath&&~isequal(sigBus.BlockPath,busBlockPaths{end})
                    sigBus=curSig.Element;
                    sigBus.Values=struct();
                    isLeafNameRepeated=true;
                end
            end
            sigTs=curSig.Element.Values;
            sigTs.Name=curSig.LeafName;
            sigTs.set('Time',curSig.TimeVals,'Data',curSig.DataVals);
            strToEval=['sigBus.Values.',fullSignalName,' = sigTs;'];
            try
                eval(strToEval);
            catch me %#ok<NASGU>


            end
            if hasBlockPath
                sigBus.BlockPath=busBlockPaths{end};
            end
            if isempty(dataSet.getElement(rootBusName))||isLeafNameRepeated
                dataSet=dataSet.addElement(sigBus,rootBusName);
            else

                elemInd=find(cellfun(@(x)strcmp(x,rootBusName),...
                dataSet.getElementNames));
                elemInd=elemInd(end);
                dataSet=setElement(dataSet,elemInd,sigBus);
            end
            if isLeafNameRepeated

                signalNamesFromFile={};
            end
        else
            sig=curSig.Element;
            sig.Name=curSig.LeafName;
            sigTs=timeseries.utcreatewithoutcheck(curSig.DataVals,curSig.TimeVals,false,false);
            sigTs.Name=curSig.LeafName;

            if~curSig.isComplex
                sigTs.Name=sig.Values.Name;
            end
            sigTs.DataInfo=sig.Values.DataInfo;
            sig.Values=sigTs;
            dataSet=dataSet.addElement(sig);
        end
    end
    this.SignalMetaData{sheetIdx}=sigData;
end