function infos=getValidInfos(obj)





    infos=getValidInfos@evolutions.internal.datautils.SerializedAbstractInfoManager(obj);
    [~,idx]=sort([infos.Created],'descend');
    infos=infos(idx);
end


