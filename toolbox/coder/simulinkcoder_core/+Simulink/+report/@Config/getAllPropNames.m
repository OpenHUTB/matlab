function out=getAllPropNames(obj)
    out=properties(obj);
    assert(strcmp(out{1},'LaunchReport'));
end
