





function flag=isSFBuiltin(mtreeNode,aParent)
    assert(isa(mtreeNode,'mtree'));
    flag=false;
    if isa(aParent,'slci.ast.SFAst')...
        &&any(strcmpi(mtreeNode.kind,{'CALL','LP'}))
        fnode=mtreeNode.Left;
        if strcmp(fnode.kind,'ID')
            fname=fnode.string;
            chart=aParent.ParentChart;
            flag=isa(chart,'slci.stateflow.Chart')...
            &&strcmpi(slci.internal.getLanguageFromSFObject(chart),'MATLAB')...
            &&any(strcmpi(fname,{'after','send'}));
        end
    end
end
