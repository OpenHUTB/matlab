function[nVals,uniqueStrs]=convertStringsToNumeric(strData,origStrs)

    nVals=zeros(size(strData),'uint32');
    strMap=containers.Map;


    for idx=1:length(origStrs)
        strMap(origStrs{idx})=uint32(idx-1);
    end

    numVals=numel(strData);
    for idx=1:numVals
        curStr=char(strData(idx));
        if isKey(strMap,curStr)
            nVals(idx)=strMap(curStr);
        else
            nVals(idx)=strMap.Count;
            strMap(curStr)=nVals(idx);
        end
    end

    strKeys=keys(strMap);
    numStrs=length(strKeys);
    uniqueStrs=cell(numStrs,1);
    for idx=1:numStrs
        curStr=strKeys{idx};
        curVal=strMap(curStr);
        uniqueStrs{curVal+1}=curStr;
    end
end
