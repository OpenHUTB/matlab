function out=foreach(h,tag,func)







    nodes=h.getElements(tag);
    out=cell(length(nodes),1);
    for k=1:length(nodes)
        out{k}=feval(func,nodes{k});
    end