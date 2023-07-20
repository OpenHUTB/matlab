

function bool=isNotUnique(model)
    import stm.internal.Coverage;
    persistent notUnique;
    if isempty(notUnique)
        notUnique=getString(message('Slvnv:simcoverage:cvdata:NotUnique'));
    end

    if iscell(model)
        model=model{1};
    end
    bool=strcmp(model,notUnique);
end
