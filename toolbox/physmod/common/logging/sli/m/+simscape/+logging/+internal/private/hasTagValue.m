function result=hasTagValue(node,name,value)



    if numel(node)>1
        node=node(1);
    end

    result=hasTag(node,name)&&all(strcmp(getTag(node,name),{name,value}));

end
