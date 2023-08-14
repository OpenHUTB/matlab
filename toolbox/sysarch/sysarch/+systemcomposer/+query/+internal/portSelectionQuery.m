function ports=portSelectionQuery(portQueryObj,modelToQuery)





    import systemcomposer.query.*;



    if isempty(portQueryObj.p_Constraint)
        ports={};
        return;
    end
    constraint=systemcomposer.query.Constraint.createFromString(portQueryObj.p_Constraint);


    rootArch=systemcomposer.arch.Architecture(modelToQuery.getRootArchitecture);


    runner=systemcomposer.query.internal.QueryRunner(rootArch,constraint,isRecursive,flattenRefs,'Port');
    runner.execute;
    ports=runner.ElemImpls;

end