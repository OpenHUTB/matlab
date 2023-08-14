function[foundIdx,channels,dims]=findDimensionColIDs(this,curName,sigNames,sigIdxs,timeIndices,ds,bp,curSigIdx)

    strippedName=curName(find(~isspace(curName)));%#ok<FNDSB>
    sigNameRx=[strippedName,this.DimsRx];


    foundIdx=[];
    channels={};
    dims=1;
    for sigIdx=curSigIdx:length(sigNames)

        thisPath=ds{sigIdx}.BlockPath;
        if(thisPath.getLength()&&~isequal(bp,thisPath))||...
            (isa(ds{sigIdx},'Simulink.SimulationData.Parameter'))

            continue
        end


        thisIdx=sigIdxs(sigIdx);
        if~isempty(foundIdx)&&thisIdx>foundIdx(end)+1
            if any((timeIndices>foundIdx(end))&(timeIndices<thisIdx))
                continue
            end
        end


        strippedName=sigNames{sigIdx}(find(~isspace(sigNames{sigIdx})));%#ok<FNDSB>
        if regexp(strippedName,sigNameRx)==1
            foundIdx(end+1)=sigIdxs(sigIdx);%#ok
            channels{end+1}=this.getSignalDimensions(strippedName);%#ok<AGROW>
        end
    end


    if~isempty(channels)
        dims=locGetFullDims(channels);
    end
end


function dims=locGetFullDims(channels)
    dims=ones(1,max(cellfun(@numel,channels)));
    for idx=1:numel(channels)
        for idx2=1:numel(channels{idx})
            if channels{idx}(idx2)>dims(idx2)
                dims(idx2)=channels{idx}(idx2);
            end
        end
    end
end
