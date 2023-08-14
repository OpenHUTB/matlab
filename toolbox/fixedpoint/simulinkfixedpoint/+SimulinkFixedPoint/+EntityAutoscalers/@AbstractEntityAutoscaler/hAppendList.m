function list=hAppendList(h,list,newList)%#ok




    L=length(newList);
    if L>0
        if isempty(list)
            list=newList;
        else
            list(end+1:end+L)=newList;
        end
    end



