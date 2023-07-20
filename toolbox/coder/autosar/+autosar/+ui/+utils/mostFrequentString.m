




function frequent_string=mostFrequentString(stringList)
    uniqueStringList=unique(stringList);
    n=length(uniqueStringList);
    if n==length(stringList)
        frequent_string=stringList{1};
        return;
    end
    counts=zeros(n,1);
    for i=1:n
        counts(i)=sum(strcmp(stringList,uniqueStringList{i}));
    end

    [~,idx]=max(counts);
    frequent_string=uniqueStringList{idx};
end
