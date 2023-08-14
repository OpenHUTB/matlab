function allowGraderDelete(model,varargin)




    if nargin>1
        graders=varargin{1};
    else


        graders=find_system(model,'MatchFilter',@Simulink.match.internal.filterOutInactiveVariantSubsystemChoices,'IncludeCommented','on','RegExp','on','ReferenceBlock','signalChecks');
    end

    for idx=1:numel(graders)
        set_param(graders{idx},'LinkStatus','none');
        set_param(graders{idx},'PreDeleteFcn','');
    end
