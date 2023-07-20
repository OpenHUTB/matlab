function names=entityNames(this)


    names=this.EntityNamelist;
    paths=this.EntityPathList;
    if~isempty(names)
        if hdlgetparameter('isvhdl')
            pkg_required=hdlgetparameter('vhdl_package_required');
            pkg_name=hdlgetparameter('vhdl_package_name');
            if pkg_required&&~isempty(names{1})&&~strcmp(names{1},pkg_name)

                logicalIndexPattern=~strcmp(names,pkg_name);
                names=[{pkg_name};names(logicalIndexPattern)];
                paths=[paths(~logicalIndexPattern);paths(logicalIndexPattern)];

                this.EntityNamelist=names;
                this.EntityPathList=paths;
            elseif~pkg_required&&~isempty(names{1})&&strcmp(names{1},pkg_name)
                names={names{2:end}};%#ok<CCAT1>
            end
        end
    else
        names={};
    end
end
