function out=getChildNodeByTagName(obj,tag)



    cNodes=obj.getElementsByTagName(tag);
    out={};
    for i=1:cNodes.getLength

        if isSameNode(cNodes.item(i-1).getParentNode,obj)
            out{end+1}=cNodes.item(i-1);%#ok<*AGROW>
        end
    end
end
