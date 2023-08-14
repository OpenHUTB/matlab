function struct=createStruct(node)




    struct='';
    n=node.getLength;

    if n==1
        struct=node.item(0).getNodeValue;
    else
        for i=1:n
            cn=node.item(i-1);
            if cn.getNodeType==1
                name=cn.getNodeName;
                struct.(name)=configset.internal.helper.createStruct(cn);
            end
        end
    end

end

