function[namesRow,mdRows]=populateMetaDataRows(this,eng,sig,namesRow,mdRows)





    bComplex=strcmpi(sig.Complexity,'complex');
    sigName=sig.Name;
    if isfield(mdRows,'dataTypeRow')
        sigDT=sig.DataType;
        bIsEnum=eng.isEnum(sig.ID);
    end
    if isfield(mdRows,'unitsRow')&&~isempty(mdRows.unitsRow)
        sigUnits=sig.Units;
    end
    if isfield(mdRows,'interpRow')&&~isempty(mdRows.interpRow)
        sigInterp=sig.InterpMethod;
    end
    if isfield(mdRows,'blockPathRow')&&~isempty(mdRows.blockPathRow)
        bpath=sig.BlockPath;
    end
    if isfield(mdRows,'portIndexRow')&&~isempty(mdRows.portIndexRow)
        sigPort=string(sig.PortIndex).char;
    end


    numChannels=1;
    id=sig.ID;
    if eng.sigRepository.isRealPartOfCompositeComplex(id)
        id=eng.sigRepository.getSignalParent(id);
    end
    if eng.sigRepository.isUnexpandedMatrixLeaf(id)
        sigDims=sig.Dimensions;
        numChannels=prod(sigDims);
    elseif eng.sigRepository.getSignalIsVarDims(id)
        ts=this.getValuesForSignal(sig);
        dv=ts.Data;
        sigDims=size(dv{1});
        numPts=numel(dv);
        for idx=1:numPts
            sigDims=max(sigDims,size(dv{idx}));
        end
        numChannels=prod(sigDims);
    end

    for idx=1:numChannels

        channelName=sigName;
        idxStr='';
        if numChannels>1
            idxStr=locGetChannelIdxStr(sigDims,idx);
            channelName=[channelName,idxStr];
        end
        if bComplex
            namesRow{end+1}=[sig.Name,idxStr,' (real)'];
            namesRow{end+1}=[sig.Name,idxStr,' (imag)'];
        else
            namesRow{end+1}=channelName;
        end


        if isfield(mdRows,'dataTypeRow')
            if bIsEnum
                mdRows.dataTypeRow{end+1}=['Enum: ',sigDT];
            else
                mdRows.dataTypeRow{end+1}=['Type: ',sigDT];
                if bComplex
                    mdRows.dataTypeRow{end+1}=['Type: ',sigDT];
                end
            end
        end
        if isfield(mdRows,'unitsRow')&&~isempty(mdRows.unitsRow)
            mdRows.unitsRow{end+1}=['Unit: ',sigUnits];
            if bComplex
                mdRows.unitsRow{end+1}=['Unit: ',sigUnits];
            end
        end
        if isfield(mdRows,'interpRow')&&~isempty(mdRows.interpRow)
            mdRows.interpRow{end+1}=['Interp: ',sigInterp];
            if bComplex
                mdRows.interpRow{end+1}=['Interp: ',sigInterp];
            end
        end
        if isfield(mdRows,'blockPathRow')&&~isempty(mdRows.blockPathRow)
            mdRows.blockPathRow{end+1}=['BlockPath: ',bpath];
            if bComplex
                mdRows.blockPathRow{end+1}=['BlockPath: ',bpath];
            end
        end
        if isfield(mdRows,'portIndexRow')&&~isempty(mdRows.portIndexRow)
            mdRows.portIndexRow{end+1}=['PortIndex: ',sigPort];
            if bComplex
                mdRows.portIndexRow{end+1}=['PortIndex: ',sigPort];
            end
        end
    end
end


function idxStr=locGetChannelIdxStr(sampleDims,channelIdx)
    dimIdx=cell(size(sampleDims));
    [dimIdx{:}]=ind2sub(sampleDims,channelIdx);
    channel=cell2mat(dimIdx);
    numDims=length(channel);
    if numDims==1
        idxStr=sprintf('(:,%d)',channel);
    else
        idxStr=sprintf('%d,',channel);
        idxStr=sprintf('(%s:)',idxStr);
    end
end
