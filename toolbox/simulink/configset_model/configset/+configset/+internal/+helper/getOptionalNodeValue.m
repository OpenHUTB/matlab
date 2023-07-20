function out=getOptionalNodeValue(root,tag,default)



    node=configset.internal.helper.getChildNodeByTagName(root,tag);
    assert(length(node)<=1);
    if isempty(node)
        out=default;
    else
        node=node{1};
        child=node.getFirstChild;
        if isempty(child)
            out='';
        else
            out=strtrim(child.getNodeValue);
        end
    end
