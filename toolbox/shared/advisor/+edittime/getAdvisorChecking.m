function val = getAdvisorChecking(model)
    if ishandle(model)
        model = get_param(model,'Name');
    end
    p=inputParser;
    addRequired(p, 'model', @(x)validateattributes(x,{'char'},...
        {'nonempty'}));
    p.parse(model);

    if~bdIsLoaded(model)
        val='off';
        return
    end
    legacyval = get_param(model, 'ShowEditTimeAdvisorChecks');
    cs=getActiveConfigSet(model);
    if cs.isValidParam('ShowAdvisorChecksEditTime')
        configsetval = get_param(model, 'ShowAdvisorChecksEditTime');
    else
        configsetval='off';
    end
    if strcmp(configsetval,'on') || strcmp(legacyval,'on')
        val='on';
    else
        val='off';
    end
end

