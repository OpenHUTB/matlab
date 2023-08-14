function instance=findInstanceFromQualifiedNameArray(this,nameArray)


    if isempty(nameArray)
        instance=this;
    else
        child=this.children.getByKey(nameArray(1));
        if isempty(child)
            instance=[];
        else
            instance=child.findInstanceFromQualifiedNameArray(nameArray(2:end));
        end
    end
end

