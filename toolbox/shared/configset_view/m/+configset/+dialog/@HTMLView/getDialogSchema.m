function dlg=getDialogSchema(obj)




    if isempty(obj.error)

        cs=obj.Source.Source;


        dlg.Items={obj.getSchema()};


        if isobject(cs)


            title=configset.internal.util.getDialogTitle(cs);
        else


            title=configset.internal.util.getDialogTitle(cs.getConfigSetSource);
        end
        dlg.DialogTitle=title;
        position=cs.ConfigPrmDlgPosition;

        if~any(position)&&isa(cs,'Simulink.ConfigSetRef')

            locSrc=cs.LocalConfigSet;
            if isa(locSrc,'Simulink.ConfigSet')
                locPos=get_param(cs.LocalConfigSet,'ConfigPrmDlgPosition');
                if any(locPos)

                    position=locPos-[20,20,0,0];
                end
            end
        end

        geometry=configset.internal.util.computeDialogPosition(position);
        if~isnan(geometry)
            dlg.Geometry=geometry;
        end


        dlg.DisableDialog=isa(cs,'DAStudio.Object')&&cs.isHierarchyReadonly;
        dlg.DisplayIcon=obj.getDisplayIcon;


        dlg.CloseMethod='close';
        dlg.CloseMethodArgs={'%dialog','%closeaction'};
        dlg.CloseMethodArgsDT={'handle','string'};

        dlg.PreApplyMethod='preApplyCallback';
        dlg.PreApplyArgs={'%dialog'};
        dlg.PreApplyArgsDT={'handle'};

        dlg.PostApplyMethod='apply';
        dlg.PostApplyArgs={'%dialog'};
        dlg.PostApplyArgsDT={'handle'};

        dlg.EmbeddedButtonSet={''};
        dlg.StandaloneButtonSet={''};


        dlg.DefaultOk=false;


        if slf_feature('get','ConfigSetKeyboard')
            dlg.IgnoreESCClose=true;
        end


        dlg.MinMaxButtons=true;
        dlg.IsScrollable=false;

    else

        dlg=configset.internal.util.errorDlg(obj.error);
    end


