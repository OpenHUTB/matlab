function[targetList,currentTgtIsUnknown]=getTargetList(hObj)





    registeredTargets=realtime.getRegisteredTargets;
    currentTgtIsUnknown=~ismember(hObj.TargetExtensionPlatform,realtime.getRegisteredTargets)&&~isequal(hObj.TargetExtensionPlatform,'None')&&~isequal(hObj.TargetExtensionPlatform,'Get more...');
    if(currentTgtIsUnknown)



        targetList=[{'None'},registeredTargets,{hObj.TargetExtensionPlatform}];
    else
        targetList=[{'None'},registeredTargets];
    end

    targetList=[targetList,{'Get more...'}];
end
