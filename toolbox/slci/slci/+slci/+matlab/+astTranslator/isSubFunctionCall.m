



function isSubFcnCall=isSubFunctionCall(mtreeNode)

    isSubFcnCall=false;

    assert(isa(mtreeNode,'mtree'));
    if any(strcmpi(mtreeNode.kind,{'CALL','LP'}))
        fnode=mtreeNode.Left;
        if strcmp(fnode.kind,'ID')
            subfcns=getSubFunctions(mtreeNode.root);
            subfcnNames=cellfun(@(x)x.Fname.string,subfcns,'UniformOutput',false);
            isSubFcnCall=any(strcmp(fnode.string,subfcnNames));
        else



            isSubFcnCall=false;
        end
    end
end


function subfcns=getSubFunctions(mtreeNode)

    fcns=mtfind(list(mtreeNode),'Kind','FUNCTION');
    indices=fcns.indices;
    numFcns=numel(indices);
    subfcns={};

    if numFcns>1
        subfcns=cell(1,numFcns-1);
        for i=2:numFcns
            index=indices(i);
            fNode=fcns.select(index);
            assert(strcmpi(fNode.kind,'FUNCTION'));
            assert(strcmpi(fNode.Fname.kind,'ID'));
            subfcns{i-1}=fNode;
        end
    end

end
