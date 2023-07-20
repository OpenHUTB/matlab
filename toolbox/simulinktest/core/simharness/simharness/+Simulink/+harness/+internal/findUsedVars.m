function vars=findUsedVars(context)

    vars={};
    obj=[];

    try
        modelH=get_param(bdroot(context),'handle');
        if Simulink.internal.isArchitectureModel(modelH)





            mdlWS=get_param(bdroot(context),'modelworkspace');
            obj=Simulink.VariableUsage(whos(mdlWS),bdroot(context));
        else
            obj=Simulink.findVars(context,'WorkspaceType','model','SearchMethod','cached');
        end
    catch ME


        if~strcmp(ME.identifier,...
            'Simulink:Data:CannotRetrieveCachedInformationBeforeUpdate')
            rethrow(ME);
        end
    end

    if~isempty(obj)
        for i=1:length(obj)
            vars{end+1}=obj(i).Name;%#ok
        end
    end
end
