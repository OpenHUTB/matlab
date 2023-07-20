function infos=getValidInfos(obj)






    idx=[obj.AllInfos.NumRefs]>0;
    infos=obj.AllInfos(idx);

end


