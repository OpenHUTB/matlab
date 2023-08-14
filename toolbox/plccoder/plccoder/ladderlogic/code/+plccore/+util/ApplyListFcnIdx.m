function ApplyListFcnIdx(list,fh)




    for i=1:length(list)
        obj=list{i};
        fh(obj,i);
    end
end
