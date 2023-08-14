function shortName=getTargetShortName(hObj)




    if ischar(hObj)
        hObj=getActiveConfigSet(hObj);
    elseif~isa(hObj,'coder.CodeConfig')&&...
        ~isa(hObj,'Simulink.ConfigSet')
        hObj=hObj.getConfigSet();
    end

    targetHardware=codertarget.targethardware.getTargetHardware(hObj);
    if~isempty(targetHardware)
        targetName=targetHardware.TargetName;
    else
        targetName=[];
    end

    shortName='';
    targets=codertarget.target.getRegisteredTargets;
    if~isempty(targetName)&&~isempty(targets)
        for i=1:numel(targets)
            if ismember(targetName,targets(i).AliasNames)||...
                isequal(targetName,targets(i).Name)
                shortName=targets(i).ShortName;
                if startsWith(shortName,'matlab:')
                    shortName=loc_evaluateShortName(hObj,targets(i).ShortName);
                end
                break
            end
        end
    end
end

function out=loc_evaluateShortName(hObj,shortName)
    out='';
    try
        out=feval(extractAfter(shortName,'matlab:'),hObj);
    catch
    end
end
