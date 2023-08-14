function removeEmbeddedSignalClassName(obj)



    newRules={};
    if isR2020aOrEarlier(obj.ver)


        newRules{end+1}='<Block<Port<EmbeddedSignalClassName:remove>>>';

        newRules{end+1}='<Block<EmbeddedSignalClassName:remove>>';
    end
    obj.appendRules(newRules);
