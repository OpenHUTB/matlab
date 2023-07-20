function out=getCoderDictionary(obj,id)



    list=strsplit(id,'/');
    n=length(list);

    out='';
    for i=1:n
        name=strjoin(list(1:i),'/');
        node=obj.getNode(name);
        if node.CodeGen==1
            out=node.CoderDictionary;
            break;
        end
    end



