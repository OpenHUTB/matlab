




function index=getEventIndex(eventData,row,runnableName)
    index=-1;
    count=-1;
    for ii=1:length(eventData)
        if strcmp(eventData(ii).RunnableName,runnableName)
            count=count+1;
            if count==row
                index=ii;
                break;
            end
        end
    end
    assert(index~=-1);
end
