function action(obj,msg)








    ref=obj.Source.Source;
    parameter=msg.arg;

    try
        switch msg.command
        case 'override'
            ref.enableOverride(parameter);
            obj.enableApplyButton(true);
        case 'push'
            ref.push(parameter);
            obj.enableApplyButton(true);
        case 'restore'
            ref.restore(parameter);
        case 'Tag_ConfigSetRef_SourceLocation'
            if isempty(parameter)
                configset.internal.util.showConfigSetInBaseWorkspace();
            else
                configset.internal.util.showConfigSetInDataDictionary(parameter);
            end
        case 'Tag_ConfigSetRef_OpenSourceAction'
            dlg=obj.Dlg;
            configset.internal.reference.openSource(ref,true,dlg);
        case 'Tag_ConfigSetRef_RefreshAction'
            c=loc_refresh(obj);%#ok<*NASGU>
            configset.internal.reference.refresh(ref);
        case 'Tag_ConfigSetRef_RestoreAllAction'
            c=loc_refresh(obj);

            ref.getConfigSetCache.restoreAll;
            ref.getConfigSetSource.restoreAll;
            obj.clearDirty();
        case 'Tag_ConfigSetRef_SourceName'
            c=loc_refresh(obj);
            ref.SourceName=parameter;
            configset.internal.reference.refresh(ref);
        case 'Tag_ConfigSetRef_SourceName2'
            c=loc_refresh(obj);
            obj.isSecondSourceNameChanged=true;











            refref=ref.getRefObject;
            refref.SourceName=parameter;
            configset.internal.reference.refresh(ref);
        end
    catch me

        obj.alert(message('configset:dialog:Error').getString,me.message);
    end

    function c=loc_refresh(obj)
        adp=obj.Source;
        adp.inReset=true;
        obj.inRefresh=true;
        c=onCleanup(@()loc_cleanup(obj));

        function loc_cleanup(obj)
            adp=obj.Source;
            adp.inReset=false;
            obj.inRefresh=false;
            adp.resetAdapter;

