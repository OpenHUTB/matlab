function name=getDefaultReqSetName(this)

    defaultName='untitled';

    reqSets=this.repository.requirementSets.toArray;

    currentNames=containers.Map('KeyType','char','ValueType','int32');
    for i=1:length(reqSets)
        reqSet=reqSets(i);


        if strcmp(reqSet.name,defaultName)

            currentNames(defaultName)=0;
            continue;
        end


        tokens=regexp(reqSet.name,['(',defaultName,')(\d+)'],'tokens','once');
        if~isempty(tokens)&&(numel(tokens)==2)
            curUntitled=str2num(tokens{2});%#ok<ST2NM>





            lastUntitled=0;
            if isKey(currentNames,defaultName)
                lastUntitled=currentNames(defaultName);
            end

            maxUntitled=max([curUntitled,lastUntitled]);

            currentNames(defaultName)=maxUntitled;
        end
    end




    if~isKey(currentNames,defaultName)
        name=defaultName;
    else

        lastUntitled=currentNames(defaultName);
        nextUntitled=lastUntitled+1;

        name=[defaultName,num2str(nextUntitled)];
    end
end