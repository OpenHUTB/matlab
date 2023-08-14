function output_args=addIncludeArguments(args,includes)


    if isempty(includes)
        output_args=args;
        return;
    end

    for index=length(includes):-1:1
        new_args{2*index}=includes(index).char;
        new_args{2*index-1}='includepath';
    end
    output_args=[args,new_args];
end
