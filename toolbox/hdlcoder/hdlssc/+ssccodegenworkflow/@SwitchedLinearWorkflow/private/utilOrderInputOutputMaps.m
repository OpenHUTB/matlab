function[stateSpaceInputMap,stateSpaceOutputMap]=utilOrderInputOutputMaps(origSubsystem,stateSpaceInputMap,stateSpaceOutputMap)







    if numel(origSubsystem)==1
        return
    end

    newOrder=zeros(numel(origSubsystem),1);
    for i=1:numel(origSubsystem)

        nameToMatch=getfullname(origSubsystem(i));
        for j=1:numel(stateSpaceInputMap)
            spsParent=get_param(stateSpaceInputMap{j}{1,1},'parent');
            if strcmp(spsParent,nameToMatch)
                newOrder(i)=j;
                break
            end
        end
    end
    stateSpaceInputMap=stateSpaceInputMap(newOrder);
    stateSpaceOutputMap=stateSpaceOutputMap(newOrder);
end


