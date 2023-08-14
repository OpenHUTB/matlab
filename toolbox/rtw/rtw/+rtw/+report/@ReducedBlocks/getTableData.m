function out=getTableData(obj,htmlEscape)
    out=cell(length(obj.Data),2);
    for k=1:length(obj.Data)
        b=obj.Data(k);
        out{k,1}=obj.getHyperlink(b.SID,b.Name);
        if htmlEscape
            out{k,2}=rtwprivate('rtwhtmlescape',b.Comment);
        else
            out{k,2}=b.Comment;
        end
    end
end
