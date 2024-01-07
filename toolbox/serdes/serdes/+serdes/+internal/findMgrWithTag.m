function appHandle=findMgrWithTag(model,appName)

    appHandle=[];
    if~isempty(model)
        h=get_param(model,'handle');
        if~isempty(h)
            tag=num2hex(h);
            appFig=findall(groot,'Type','figure','Tag',tag);

            if~isempty(appFig)
                for figIdx=1:numel(appFig)
                    fig=appFig(figIdx);
                    app=fig.RunningAppInstance;
                    if~isempty(app)&&isvalid(app)&&isa(app,appName)
                        appHandle=app;
                        break;
                    end
                end
            end
        end
    end
end