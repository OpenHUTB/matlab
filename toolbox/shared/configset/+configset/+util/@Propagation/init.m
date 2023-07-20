function init(h,mdl,backup,gui)

    h.GUI=gui;
    h.TopModel=mdl;
    h.CS=getActiveConfigSet(mdl);


    mdls=find_mdlrefs(mdl,'MatchFilter',@Simulink.match.internal.filterOutCodeInactiveVariantSubsystemChoices,'IncludeProtectedModels',true);
    mdls(end)=[];
    h.Number=length(mdls);

    h.IsPropagated=false;
    h.SaveName=backup;

    h.Map=containers.Map;

    for i=1:h.Number
        mdl=mdls{i};
        [~,mdl,~]=fileparts(mdl);
        m=configset.util.Model(mdl);
        m.GUI=gui;
        h.Map(mdl)=m;
    end
