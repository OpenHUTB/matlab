

function isInnerFunc=isInnerFunctionCall(mtreeNode)

    isInnerFunc=false;

    assert(isa(mtreeNode,'mtree'));
    if any(strcmpi(mtreeNode.kind,{'CALL','LP'}))
        fnode=mtreeNode.Left;
        if strcmp(fnode.kind,'ID')
            innerFcns=getInnerFunctions(mtreeNode.root);
            innerFcnNames=cellfun(@(x)x.Fname.string,innerFcns,'UniformOutput',false);
            isInnerFunc=any(strcmp(fnode.string,innerFcnNames));
        else



            isInnerFunc=false;
        end
    end
end


function subfcns=getInnerFunctions(mtreeNode)

    fcns=mtfind(list(mtreeNode.Body),'Kind','FUNCTION');
    indices=fcns.indices;
    numFcns=numel(indices);

    subfcns=cell(1,numFcns);
    for i=1:numFcns
        index=indices(i);
        fNode=fcns.select(index);
        assert(strcmpi(fNode.kind,'FUNCTION'));
        assert(strcmpi(fNode.Fname.kind,'ID'));
        subfcns{i}=fNode;
    end

end