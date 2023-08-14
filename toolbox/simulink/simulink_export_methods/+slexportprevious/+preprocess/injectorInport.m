function injectorInport(obj)







    objVersion=obj.ver;
    if isR2019bOrEarlier(objVersion)
        obj.appendRule('<Block<BlockType|InjectorInport>:remove>');
    end
end
