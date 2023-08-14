function defines_out=convertDefineToSourceStyle(defines)


    defines_out=string.empty();
    for index=length(defines):-1:1
        define=defines(index).erase("-D");
        parts=define.split("=");
        if length(parts)==1
            defines_out(index)=sprintf("#define %s",parts);
        else
            defines_out(index)=sprintf("#define %s %s",parts(1),parts(2));
        end
    end
end