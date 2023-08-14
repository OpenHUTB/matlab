function injectorOutport(obj)







    objVersion=obj.ver;
    if isR2019bOrEarlier(objVersion)
        obj.appendRule('<Block<BlockType|InjectorOutport>:remove>');
    end
end
