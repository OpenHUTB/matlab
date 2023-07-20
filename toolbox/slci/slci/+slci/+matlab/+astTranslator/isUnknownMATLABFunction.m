



function flag=isUnknownMATLABFunction(mtreeNode)

    assert(isa(mtreeNode,'mtree'));
    if any(strcmpi(mtreeNode.kind,{'CALL','LP'}))
        fnode=mtreeNode.Left;
        if strcmp(fnode.kind,'ID')
            fname=fnode.string;
            flag=ismember(exist(fname),[2,5,6]);%#ok<EXIST>
        else



            flag=false;
        end
    else
        flag=false;
    end
end
