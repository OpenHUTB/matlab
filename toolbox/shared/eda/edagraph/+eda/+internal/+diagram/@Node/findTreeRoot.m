function root=findTreeRoot(this)







    root=this.getParent;
    if isempty(root)
        root=this;
    else
        root=findTreeRoot(root);
    end
end

