function buildWorkflow=getBuildWorkflow(ctx)





    if~isempty(ctx)
        if isa(ctx.ConfigData,'Simulink.ConfigSet')
            if strcmp(ctx.CodeGenTarget,'sfun')
                buildWorkflow='simulation';
            elseif strcmp(ctx.CodeGenTarget,'rtw')
                buildWorkflow='simulink';
            else
                error('Unrecognized CodeGenTarget in Simulink.ConfigSet in getBuildWorkflow.m');
            end
        elseif isa(ctx.ConfigData,'coder.Config')
            buildWorkflow='matlab';
        else
            error('Unrecognized type of ctx.ConfigData in getBuildWorkflow.m');
        end
    else
        buildWorkflow='simulation';
    end

end
