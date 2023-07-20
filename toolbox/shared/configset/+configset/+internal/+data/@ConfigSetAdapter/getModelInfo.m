function out=getModelInfo(obj)




    out=[];
    out.resolved=true;

    adp=obj;
    hSrc=adp.Source;
    mdlH=hSrc.getModel;


    if~isempty(mdlH)
        model.name=get_param(mdlH,'Name');
        model.configsets=getConfigSets(mdlH);
        model.active=get_param(getActiveConfigSet(mdlH),'Name');
        out.model=model;
    end


    if~isa(hSrc,'Simulink.ConfigSetRef')
        return;
    end




    if hSrc.UpToDate=="off"
        if hSrc.IsDialogCache=="on"
            hSrc.getConfigSetSource.refresh(true);
        end
        hSrc.refresh(true);
    end
    if~isempty(hSrc.LocalConfigSet)
        hSrc.LocalConfigSet.lock;
        cleanupTask=onCleanup(@()hSrc.LocalConfigSet.unlock);
    end
    try
        hSrc.getRefConfigSet;
        if isempty(hSrc.LocalConfigSet)
            hSrc.refresh('LocalConfigSet');
        end
    catch ME
        out.resolved=false;
        out.errmsg=configset.internal.util.getConfigSetRefDiagnosticMessage(ME,true);
    end


    refInfo={};
    ref=hSrc;
    while isa(ref,'Simulink.ConfigSetRef')
        s=[];
        [s.srcList,s.refList,s.csList,s.refExtra,s.csExtra]=...
        configset.internal.util.getReferenceableConfigSets(ref);
        s.src=ref.SourceName;
        s.enabled=~ref.isReadonlyProperty('SourceName');
        s.override=ref.SourceResolved=="on"&&...
        isa(ref.LocalConfigSet,'Simulink.ConfigSetRoot')&&...
        ~ref.isObjectLocked&&~isempty(ref.ParameterOverrides);

        if~isempty(ref.DDName)&&ref.SourceResolvedInBaseWorkspace=="off"
            s.loc=ref.DDName;
        else
            s.loc='';
        end
        s.ddname=ref.DDName;

        try

            ref=ref.getRefObject;
            s.resolved=true;
        catch ME
            ref=[];
            s.resolved=false;
            s.errmsg=ME.message;
        end

        refInfo{end+1}=s;%#ok<AGROW>
    end
    out.ref=refInfo;




