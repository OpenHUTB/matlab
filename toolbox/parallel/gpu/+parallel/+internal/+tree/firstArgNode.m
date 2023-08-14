function argNode=firstArgNode(node)















    argNode=Right(node);
    if~isnull(argNode)&&iskind(argNode,'NAMEVALUE')
        argNode=Left(argNode);
    end
end
