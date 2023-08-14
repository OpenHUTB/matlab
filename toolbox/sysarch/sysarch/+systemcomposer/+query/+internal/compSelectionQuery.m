function comps=compSelectionQuery(compQueryObj,modelToQuery,isRecursive,flattenRefs)





    import systemcomposer.query.*;



    if isempty(compQueryObj.p_Constraint)
        comps={};
        return;
    end
    constraint=systemcomposer.query.Constraint.createFromString(compQueryObj.p_Constraint);


    rootArch=systemcomposer.arch.Architecture(modelToQuery.getRootArchitecture);


    runner=systemcomposer.query.internal.QueryRunner(rootArch,constraint,isRecursive,flattenRefs,'Component');
    runner.execute;
    comps=runner.ElemImpls;

end
