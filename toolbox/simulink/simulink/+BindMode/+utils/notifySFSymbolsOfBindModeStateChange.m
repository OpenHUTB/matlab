

function notifySFSymbolsOfBindModeStateChange(model,isEnabled)
    modelHandle=get_param(model,'Handle');
    studioApps=SLM3I.SLDomain.getAllStudioAppsFor(modelHandle);
    for studioIdx=1:numel(studioApps)
        studio=studioApps(studioIdx).getStudio();
        studioTag=studio.getStudioTag();


        try

            symbolManager=feval('Stateflow.internal.SymbolManager.GetSymbolManagerForStudio',studioTag);%#ok<FVAL>
            if~isempty(symbolManager)&&symbolManager~=0&&isvalid(symbolManager)
                symbolManager.setBindModeStatus(isEnabled);
            end
        catch
        end
    end
end