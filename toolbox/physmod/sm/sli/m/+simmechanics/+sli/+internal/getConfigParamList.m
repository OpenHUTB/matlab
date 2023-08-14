function cpList=getConfigParamList()


    cpTree=simmechanics.sli.internal.getConfigParamTree;

    cpList=visit_compound_node(cpTree);

end

function cpList=visit_compound_node(aCompoundNode)

    cpList=[];
    children=aCompoundNode.getChildren;
    for idx=1:length(children)
        if isa(children{idx},'pm.util.SimpleNode')
            cpList=[cpList,visit_simple_node(children{idx})];
        else
            cpList=[cpList,visit_compound_node(children{idx})];
        end
    end

end

function cpList=visit_simple_node(aSimpleNode)
    cpList=[];
    cparams=aSimpleNode.Info.Parameters;
    props=properties(simmechanics.sli.internal.ConfigurationParameter);
    for idx=1:length(cparams)
        for idxA=1:length(props)
            cpStruct.(props{idxA})=cparams(idx).(props{idxA});
        end
        cpList=[cpList,cpStruct];
    end
end

