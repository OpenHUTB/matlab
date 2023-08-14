function obj=searchObjectsInWorkspace(model,name,objectType)

    obj={};


    baseWSVariables=evalin('base','who');
    index=find(strcmp(baseWSVariables,name),1);
    if~isempty(index)&&evalin('base',['isa(',name,',''',objectType,''')'])
        obj=evalin('base',name);
        return;
    end


    evalWS=get_param(model,'ModelWorkspace');
    modelWSVariables=evalWS.evalin('who');
    index=find(strcmp(modelWSVariables,name),1);
    if~isempty(index)&&evalWS.evalin(['isa(',name,',''',objectType,''')'])
        obj=evalWS.evalin(name);
        return;
    end


    if Simulink.data.existsInGlobal(model,name)
        dataObj=Simulink.data.evalinGlobal(model,name);
        if isa(dataObj,objectType)
            obj=dataObj;
            return;
        end
    end




    maskedBlock=find_system(model,'LookUnderMasks','All',...
    'MatchFilter',@Simulink.match.internal.filterOutInactiveVariantSubsystemChoices,...
    'FindAll','on','Mask','on','Type','block');
    for i=1:length(maskedBlock)
        mask=Simulink.Mask.get(maskedBlock(i));
        maskWSVariables=mask.getWorkspaceVariables;
        for m=1:length(maskWSVariables)
            if strcmp(maskWSVariables(m).Name,name)&&...
                isa(maskWSVariables(m).Value,objectType)
                obj=maskWSVariables(m).Value;
                return;
            end
        end
    end
end