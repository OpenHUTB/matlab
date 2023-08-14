function count=trackCallCount(lifecycleName,increment)
    persistent callCounts
    if isempty(callCounts)
mlock
        callCounts=struct;
    end

    count=0;
    if isfield(callCounts,lifecycleName)
        count=callCounts.(lifecycleName);
    end

    if nargin>1&&increment==true
        count=count+1;
        callCounts.(lifecycleName)=count;
    end
end
