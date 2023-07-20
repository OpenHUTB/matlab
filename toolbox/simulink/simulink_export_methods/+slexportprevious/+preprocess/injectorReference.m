function injectorReference(obj)







    objVersion=obj.ver;
    if isR2019bOrEarlier(objVersion)
        obj.appendRule('<Block<BlockType|InjectorReference>:remove>');
    end
end
