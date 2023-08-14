function clearScopes(obj)



    dialog=obj.pParameters.CurrentDialog;
    resetCustomVisuals(dialog);


    if obj.pPlotConstellation&&~isempty(obj.pConstellation)

        clearScope(obj.useAppContainer,obj.pConstellation,'DisplayLine|Sub');
    end
    if obj.pPlotTimeScope&&~isempty(obj.pTimeScope)
        clearScope(obj.useAppContainer,obj.pTimeScope,'DisplayLine');
    end
    if obj.pPlotSpectrum&&~isempty(obj.pSpectrum1)
        clearScope(obj.useAppContainer,obj.pSpectrum1,'DisplayLine');
    end

end

function clearScope(useAppContainer,scope,tag)
    if useAppContainer
        scope(nan(1e4,1));
    else
        frameWork1=getFramework(scope);
        fig=frameWork1.Parent;
        l=findobj(fig,'-regexp','Tag',tag);
        set(l,'XData',NaN,'YData',NaN);
    end
end
