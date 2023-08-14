function iterator=createArchitectureIterator(traversalOrder)





    if nargin<1
        traversalOrder=systemcomposer.IteratorDirection.PreOrder;
    end

    iterator=internal.systemcomposer.ArchitectureIterator(traversalOrder);

end