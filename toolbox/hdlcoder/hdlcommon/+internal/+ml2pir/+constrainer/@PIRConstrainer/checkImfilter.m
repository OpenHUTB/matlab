function checkImfilter(this,node)






    imageArg=node.Right;
    filterArg=imageArg.Next;


    if~this.isConst(filterArg)
        this.addMessage(node,...
        internal.mtree.MessageType.Error,...
        'hdlcommon:matlab2dataflow:ImfilterNonConstFilterArg',...
        filterArg.tree2str);
    end
end
