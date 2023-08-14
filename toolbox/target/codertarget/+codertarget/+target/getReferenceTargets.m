function target=getReferenceTargets(targetName)





    target='';
    targets=codertarget.target.getRegisteredTargets();
    targetNames={targets(:).Name};
    [found,idx]=ismember(targetName,targetNames);
    if found
        target=targets(idx).ReferenceTargets;
    end
end