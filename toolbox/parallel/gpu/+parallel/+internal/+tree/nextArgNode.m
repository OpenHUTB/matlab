function nextArg=nextArgNode(node)

















    if iskind(Parent(node),'NAMEVALUE')
        if iskind(node,'FIELD')

            nextArg=Right(Parent(node));
        else


            nextArg=parallel.internal.tree.nextArgNode(Parent(node));
        end
    else
        nextArg=Next(node);
        if iskind(nextArg,'NAMEVALUE')

            nextArg=nextArg.Left;
        end
    end
end
