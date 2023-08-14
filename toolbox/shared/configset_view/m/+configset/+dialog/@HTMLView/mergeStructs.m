function merged=mergeStructs(s1,s2)

    merged=s1;
    if~isempty(s2)
        f=fieldnames(s2);
        for i=1:length(f)
            merged.(f{i})=s2.(f{i});
        end
    end

end

