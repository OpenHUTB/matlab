function clearParameterHighlights(csOrModel,~)

    narginchk(1,2);

    if isa(csOrModel,'Simulink.ConfigSetRoot')
        cs=csOrModel;
    else
        cs=getActiveConfigSet(csOrModel);
    end

    view=configset.internal.util.getHTMLView(cs);
    if~isempty(view)
        view.clearHighlights;
    end




