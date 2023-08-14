function[index,nearestTs]=getTimeToIndex(timeVector,ts)



    idx=find(timeVector>=ts,1);
    if isempty(idx)
        index=numel(timeVector);
        nearestTs=timeVector(end);
    else
        value=timeVector(idx);
        if value~=ts
            index=max(1,idx-1);
            nearestTs=timeVector(index);
        else
            index=idx;
            nearestTs=ts;
        end
    end
end