function str=textLiteralContents(node)














    k=kind(node);
    str=string(node);
    if strcmp(k,'CHARVECTOR')||strcmp(k,'STRING')

        str=str(2:end-1);
    end
end
