function entries=GetMaskEntries(block)




    oldEntries=get_param(block,'MaskValueString');
    if~isempty(oldEntries),
        k=find(oldEntries=='|');
    else
        k=[];
    end

    k=[0,k,length(oldEntries)+1];

    entries=cell(length(k)-1,1);
    for i=length(k)-1:-1:1
        entries{i}=oldEntries(k(i)+1:k(i+1)-1);
    end

end
