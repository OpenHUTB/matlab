function constructBuiltinRepRulesTree(obj)




    obj.initOpenedModelList();

    obj.BlkRepRulesTree=Sldv.xform.CompBlkRepRule;


    childBlkRepRule=Sldv.xform.CompBlkRepRule;
    childBlkRepRule.BlockType='Built-in';
    obj.BlkRepRulesTree.addRule(childBlkRepRule);
    obj.BuiltinBlkRepRulesTree=childBlkRepRule;


    childBlkRepRule=Sldv.xform.CompBlkRepRule;
    childBlkRepRule.BlockType='ModelReference';
    obj.BlkRepRulesTree.addRule(childBlkRepRule);
    obj.MdlRefBlkRepRulesTree=childBlkRepRule;


    childBlkRepRule=Sldv.xform.CompBlkRepRule;
    childBlkRepRule.BlockType='SubSystem';
    obj.BlkRepRulesTree.addRule(childBlkRepRule);
    obj.SubSystemRepRulesTree=childBlkRepRule;

    priorityIdx=1;
    ruleMfiles=Sldv.xform.BlkReplacer.autoBlkRepRules;
    for i=1:length(ruleMfiles)
        childBlkRepRule=sldvprivate(ruleMfiles{i});
        childBlkRepRule.IsBuiltin=true;
        childBlkRepRule.IsAuto=true;
        childBlkRepRule.Priority=priorityIdx;
        obj.BlkRepRulesTree.addRule(childBlkRepRule);
        priorityIdx=priorityIdx+1;
    end

    ruleMfiles=Sldv.xform.BlkReplacer.factoryDefaultBlkRepRules;
    for i=1:length(ruleMfiles)
        childBlkRepRule=sldvprivate(ruleMfiles{i});
        childBlkRepRule.IsBuiltin=true;
        childBlkRepRule.Priority=priorityIdx;
        obj.BlkRepRulesTree.addRule(childBlkRepRule);
        priorityIdx=priorityIdx+1;
    end

    if slavteng('feature','SSysStubbing')
        stubBlkRepRule=obj.createRuleForStubbing;
        stubBlkRepRule.IsBuiltin=true;
        stubBlkRepRule.IsAuto=true;
        stubBlkRepRule.Priority=priorityIdx;
        obj.BlkRepRulesTree.addRule(stubBlkRepRule);
    end
end