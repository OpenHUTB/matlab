function newList=parseList(c,oldList)






    if nargin<2
        oldList=c.ObjectList;
    end



    newList={};
    for i=1:length(oldList)
        currString=oldList{i};
        if isempty(currString)

        elseif strncmp(currString,'%<',2)&strcmp(currString(end),'>')

            currString=currString(3:end-1);
            try
                rezString=evalin('base',currString);
            catch
                rezString=[];
            end

            if ischar(rezString)&size(rezString,1)==1
                newList{end+1,1}=rezString;
            elseif iscell(rezString)&min(size(rezString))==1
                newList=[newList(:);rezString(:)];
            elseif isnumeric(rezString)&min(size(rezString))==1
                rezString=num2cell(rezString);
                newList=[newList(:);rezString(:)];
            end
        else
            newList{end+1,1}=currString;
        end
    end



    try
        newList=find_system(newList,'SearchDepth',0);
        badBlockList=[];
    catch


        badList=[];
        if iscell(newList),ic=1;else ic=0;end
        for i=1:length(newList)
            if ic,curItem=newList{i};else curItem=newList(i);end
            try
                find_system(curItem,'SearchDepth',0);
            catch
                badList=[badList,i];
            end
        end
        badBlockList=newList(badList);
        newList(badList)=[];
    end
