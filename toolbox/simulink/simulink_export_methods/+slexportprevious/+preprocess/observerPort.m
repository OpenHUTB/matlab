function observerPort(obj)







    objVersion=obj.ver;
    if isR2018bOrEarlier(objVersion)
        obj.appendRule('<Block<BlockType|ObserverPort>:remove>');
    end
end
