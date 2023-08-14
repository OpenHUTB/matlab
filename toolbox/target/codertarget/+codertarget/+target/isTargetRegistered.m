function ret=isTargetRegistered(name)





    targetNames=codertarget.target.getRegisteredTargetNames();
    ret=ismember(name,targetNames);
end