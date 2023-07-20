function h=loadBackup(file,mdl,gui)

    b=load(file);
    h=b.infoStruct;

    h.GUI=gui;
    h.TopModel=mdl;
    h.CS=getActiveConfigSet(mdl);


    mdls=find_mdlrefs(mdl,'MatchFilter',@Simulink.match.internal.filterOutCodeInactiveVariantSubsystemChoices,'IncludeProtectedModels',true);
    mdls(end)=[];
    h.Number=length(mdls);
    h.SaveName=file;

    map=h.Map;
    h.Map=containers.Map;
    for i=1:h.Number
        mdl=mdls{i};
        [~,mdl,~]=fileparts(mdl);
        if map.isKey(mdl)
            m=map(mdl);
        else
            m=configset.util.Model(mdl);
        end
        m.GUI=gui;
        h.Map(mdl)=m;
    end

