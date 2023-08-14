function out=getMultipleNodeValues(root,tag)



    nodes=configset.internal.helper.getChildNodeByTagName(root,tag);
    if isempty(nodes)
        out={};
    else
        out=cell(length(nodes),1);
        for k=1:length(nodes)
            node=nodes{k};
            child=node.getFirstChild;
            if isempty(child)
                out{k}='';
            else
                out{k}=strtrim(child.getNodeValue);
            end
        end
    end
