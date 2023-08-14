function matview(filename,varname,basevarsuffix)






    if nargin<3
        basevarsuffix='';
    end
    refname=comparisons.internal.loadVariable(filename,varname,basevarsuffix);
    openvar(refname);
end
