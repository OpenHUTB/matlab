function relTag=getReleaseTag(release,opt)

    validateattributes(release,{'char','string'},{'nonempty','scalartext'});
    validateattributes(opt,{'char','string'},{});
    relTag=regexprep(release,'[\s|(|)]','');
    if~exist('opt','var')||~strcmpi(opt,'matchcase')
        relTag=lower(relTag);
    end
end