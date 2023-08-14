function to=copyStructContent(target,from)

    to=target;
    if(~isstruct(from))
        return;
    end

    fields=fieldnames(from);
    for k=1:length(fields)
        to.(fields{k})=from.(fields{k});
    end
end

