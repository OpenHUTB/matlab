



function flag=isFunctionCall(mtreeNode)

    assert(isa(mtreeNode,'mtree'));
    if any(strcmpi(mtreeNode.kind,{'CALL','LP'}))
        fnode=mtreeNode.Left;
        if strcmp(fnode.kind,'ID')
            fname=fnode.string;
            val=exist(fname);%#ok
            validValues=[2,6];







            flag=~isempty(find(validValues==val,1));
        else



            flag=false;
        end
    else
        flag=false;
    end
end
