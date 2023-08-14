


function flag=isMatlabFunction(mtreeNode)

    assert(isa(mtreeNode,'mtree'));
    flag=false;

    if any(strcmpi(mtreeNode.kind,{'CALL','LP'}))
        fnode=mtreeNode.Left;
        if strcmp(fnode.kind,'ID')
            fname=fnode.string;
            fSupportedFuncs={'mean','dot','cross','deg2rad','rad2deg'};
            flag=ismember(fname,fSupportedFuncs);
        end
    end
end
