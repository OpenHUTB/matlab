function targetName=getTargetNameForAlias(name)





    validateattributes(name,{'char'},{});
    targetName=name;
    targets=codertarget.target.getRegisteredTargets();
    aliasNames={targets(:).AliasNames};
    targetNames={targets(:).Name};

    matchesAliasName=cellfun(@(x)any(ismember(x,name)),aliasNames);
    idx=find(matchesAliasName);

    if~isempty(idx)
        targetName=targetNames{idx};
    end
end