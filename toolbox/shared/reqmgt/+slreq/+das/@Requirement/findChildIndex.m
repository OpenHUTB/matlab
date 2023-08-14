function index=findChildIndex(this)






    index=0;
    children=this.parent.children;
    for i=1:numel(children)
        if this==children(i)
            index=i;
            break;
        end
    end
end
