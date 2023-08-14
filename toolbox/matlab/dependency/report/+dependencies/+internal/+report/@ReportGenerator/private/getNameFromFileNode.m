function name=getNameFromFileNode(node)




    location=node.Location{1};
    [~,name,ext]=fileparts(location);
    name=string(strcat(name,ext));
end
