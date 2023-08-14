function clear(obj)





    infosToDelete=obj.Infos;
    for idx=1:numel(infosToDelete)
        info=infosToDelete(idx);
        obj.remove(info);
        evolutions.internal.utils.deleteHandle(info);
    end

end
