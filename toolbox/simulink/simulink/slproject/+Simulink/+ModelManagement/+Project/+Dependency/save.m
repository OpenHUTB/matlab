function save(jNode,close)







    node=convertVertex(jNode);
    dependencies.internal.action.save(node);
    if close
        dependencies.internal.action.close(node);
    end

end
