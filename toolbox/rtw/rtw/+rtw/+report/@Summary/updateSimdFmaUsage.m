function updateSimdFmaUsage(obj,modelName)
    instructionExtensions=get_param(modelName,'InstructionSetExtensions');
    if~isempty(instructionExtensions)&&~ismember('None',instructionExtensions)
        obj.InstructionSetExtensions=strjoin(instructionExtensions,',');
        tfl=get_param(modelName,'TargetFcnLibHandle');
        obj.IsFmaTriggered=loc_getIsFmaTriggered(tfl);
    else
        obj.InstructionSetExtensions='None';
        obj.IsFmaTriggered=false;
    end

end


function fmaTriggered=loc_getIsFmaTriggered(aTfl)
    fmaTriggered=false;
    aHitCache=aTfl.HitCache;
    for idx=1:length(aHitCache)
        if strcmp(aHitCache(idx).Key,'vmac')||strcmp(aHitCache(idx).Key,'vmas')
            fmaTriggered=true;
            break;
        end
    end
end
