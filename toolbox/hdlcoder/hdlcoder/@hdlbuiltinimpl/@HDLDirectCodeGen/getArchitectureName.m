function archName=getArchitectureName(this)









    names=this.ArchitectureNames;

    if isempty(names)
        archName='default';%#ok<*AGROW>
    else
        archName=names{1};
    end
