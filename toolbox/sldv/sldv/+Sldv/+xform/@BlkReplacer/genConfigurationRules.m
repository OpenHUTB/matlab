function rulesConfiguration=genConfigurationRules(obj,listrules)




    allRules=obj.AllRules;
    lenNonAutoRules=numel(obj.AllRules)-numel(obj.AllActiveAutoRules);


    typeColumn=cell(1,lenNonAutoRules);
    mfileColumn=cell(1,lenNonAutoRules);
    bltypeColumn=cell(1,lenNonAutoRules);
    priorityColumn=cell(1,lenNonAutoRules);
    activityColumn=cell(1,lenNonAutoRules);

    currEl=1;
    typeVals={getString(message('Sldv:xform:BlkReplacer:BlkReplacer:BuiltInRepRuleType')),getString(message('Sldv:xform:BlkReplacer:BlkReplacer:CustomRepRuleType'))};
    typeColumn(currEl)={getString(message('Sldv:xform:BlkReplacer:BlkReplacer:RepRuleTypeColName'))};
    mfileColumn(currEl)={getString(message('Sldv:xform:BlkReplacer:BlkReplacer:RepRuleFileColName'))};
    bltypeColumn(currEl)={getString(message('Sldv:xform:BlkReplacer:BlkReplacer:RepRuleBlkTypeColName'))};
    priorityColumn(currEl)={getString(message('Sldv:xform:BlkReplacer:BlkReplacer:RepRulePriorityColName'))};
    activityColumn(currEl)={getString(message('Sldv:xform:BlkReplacer:BlkReplacer:RepRuleActivityColName'))};

    for idx=1:length(allRules)


        if allRules{idx}.IsAuto
            continue;
        end
        currEl=currEl+1;
        is_built_in=allRules{idx}.IsBuiltin;
        typeColumn(currEl)=typeVals(2-double(is_built_in));

        validTypes={allRules{idx}.BlockType};
        if~isempty(validTypes)
            blrepCnt=length(validTypes);
            validTypes(1:2:(2*blrepCnt-1))=validTypes;
            validTypes(2:2:end)={' '};
            blrepStr=[validTypes{:}];
        else
            blrepStr='';
        end
        bltypeColumn{currEl}=blrepStr;

        regPath=allRules{idx}.FileName;
        mfileColumn{currEl}=[regPath,'.m'];

        priorityColumn{currEl}=num2str(allRules{idx}.Priority);
        activityColumn{currEl}=num2str(allRules{idx}.IsActive);
    end

    rulesConfiguration.typeColumn=typeColumn;
    rulesConfiguration.mfileColumn=mfileColumn;
    rulesConfiguration.bltypeColumn=bltypeColumn;
    rulesConfiguration.priorityColumn=priorityColumn;
    rulesConfiguration.activityColumn=activityColumn;

    if listrules
        disp(getString(message('Sldv:xform:BlkReplacer:genConfigurationRules:ConfigurationBlockReplacement')));
        spaceCol=char(32*ones(length(typeColumn),2));
        info=[char(typeColumn(:)),spaceCol,char(mfileColumn(:)),spaceCol,...
        char(bltypeColumn(:)),spaceCol,char(priorityColumn(:)),spaceCol,...
        char(activityColumn(:))];

        disp(' ');
        disp(info);
        disp(' ');
    end
end