



function flag=isBuiltin(mtreeNode)

    assert(isa(mtreeNode,'mtree'));
    if any(strcmpi(mtreeNode.kind,{'CALL','LP'}))
        fnode=mtreeNode.Left;
        if strcmp(fnode.kind,'ID')
            fname=fnode.string;
            flag=exist(fname,'builtin');
        else



            flag=false;
        end
    else
        flag=false;
    end
end
