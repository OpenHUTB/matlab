function observerReference(obj)







    objVersion=obj.ver;
    if isR2018bOrEarlier(objVersion)
        obj.appendRule('<Block<BlockType|ObserverReference>:remove>');
    end
end
