function ApplyListFcn(list,fh)




    for i=1:length(list)
        obj=list{i};
        fh(obj);
    end
end
