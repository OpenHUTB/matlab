function selectPlatform(platform,cbinfo)




    if~cbinfo.EventData
        return;
    end

    studio=cbinfo.studio;
    refresher=coder.internal.toolstrip.util.Refresher(studio);%#ok<NASGU>

    mdl=cbinfo.editorModel.handle;
    switch platform
    case 'NativeC'
        set_param(mdl,'PlatformDefinition','');
        set_param(mdl,'TargetLang','C');
    case 'NativeCPP'
        set_param(mdl,'PlatformDefinition','');
        set_param(mdl,'TargetLang','C++');
    case 'FC'
        ecd=get_param(mdl,'EmbeddedCoderDictionary');
        if~isempty(ecd)
            hlp=coder.internal.CoderDataStaticAPI.getHelper();
            list=hlp.getSoftwarePlatforms(ecd);
            for i=1:length(list)
                pf=list(i);
                if strcmp(pf.PlatformType,'ServiceInterfaceConfiguration')
                    coder.internal.toolstrip.util.changePlatformWarningDlg(mdl,pf.Name,pf.Name);
                    break;
                end
            end
        end
    end


