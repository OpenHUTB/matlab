function registerTarget(reg,targetDefinition,onlyAddFcns)




    if nargin<3


        onlyAddFcns=false;
    end
    if isempty(targetDefinition)
        return;
    end

    if(isa(targetDefinition,'function_handle'))
        if onlyAddFcns

            addTargetFcns(reg,targetDefinition)
        else
            addTarget(reg,targetDefinition);
        end
    else
        TargetFiles=cellstr(targetDefinition);
        for i=1:length(TargetFiles)
            if onlyAddFcns

                addTargetFcns(reg,TargetFiles{i})
            else
                addTarget(reg,TargetFiles{i});
            end
        end
    end
end


function addTarget(reg,TargetName)
    if(~isa(TargetName,'function_handle'))
        if~ischar(TargetName)||isempty(which(TargetName))
            return;
        end
        TargetName=str2func(TargetName);
    end
    thisTarget=TargetName();
    TargetName=thisTarget.Name;
    if isTargetRegistered(reg,TargetName)
        return;
    end
    if isfield(thisTarget,'ShortName')
        ShortName=thisTarget.ShortName;
    else
        ShortName='';
    end
    TargetFolder=thisTarget.TargetFolder;
    ReferenceTargets={};
    if isfield(thisTarget,'ReferenceTargets')
        ReferenceTargets=thisTarget.ReferenceTargets;
    end
    AliasNames={};
    if isfield(thisTarget,'AliasNames')
        AliasNames=thisTarget.AliasNames;
    end
    if isfield(thisTarget,'TargetType')
        TargetType=thisTarget.TargetType;
    else
        TargetType=-1;




    end
    if isfield(thisTarget,'TargetVersion')
        TargetVersion=thisTarget.TargetVersion;
    else
        TargetVersion=1;


    end
    len=length(reg.Targets);
    reg.Targets(len+1).Name=TargetName;
    reg.Targets(len+1).TargetFolder=TargetFolder;
    reg.Targets(len+1).TargetType=TargetType;
    reg.Targets(len+1).TargetVersion=TargetVersion;
    reg.Targets(len+1).ReferenceTargets=ReferenceTargets;
    reg.Targets(len+1).ShortName=ShortName;
    reg.Targets(len+1).AliasNames=AliasNames;
end



function addTargetFcns(reg,TargetName)
    if(~isa(TargetName,'function_handle'))
        if~ischar(TargetName)||isempty(which(TargetName))
            return;
        end
        TargetName=str2func(TargetName);
    end
    if isTargetRegistered(reg,TargetName)
        return;
    end
    reg.FcnHandles{end+1}=TargetName;
end
