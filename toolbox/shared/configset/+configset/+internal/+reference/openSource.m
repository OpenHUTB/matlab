function out=openSource(ref,chase,refdlg)












    out=[];
    dlg=[];
    if isa(ref,'DAStudio.Dialog')
        if isa(ref.getDialogSource,'Simulink.dd.EntryDDGSource')

            dlg=ref;
            ref=ref.getDialogSource;
            ref=ref.m_entryInfo.Value;
        else
            ref=ref.getDialogSource;
        end
    end
    if~isa(ref,'Simulink.ConfigSetRef')
        return
    end
    if nargin<2
        chase=true;
    end
    if nargin<3
        refdlg=ref.getDialogHandle;
    end

    sourceCS=configset.util.getSource(ref,chase);
    if~isempty(sourceCS)
        inDataDictionary=(ref.SourceLocation=="Data Dictionary");
        if isa(sourceCS,'Simulink.ConfigSet')
            if inDataDictionary
                sourceCS.IsReferenced=true;
            end
            if(~isempty(ref.getModel))
                sourceCS.ReferenceModelContext=get_param(ref.getModel,'Name');
            end
        end
        if isa(sourceCS,'Simulink.ConfigSetRef')
            if inDataDictionary
                configset.internal.util.showConfigSetInDataDictionary(ref.DDName,ref.SourceName);
            else
                configset.internal.util.showConfigSetInBaseWorkspace(ref.SourceName);
            end
        else

            if slfeature('ConfigSetRefOverride')
                sourceCS.CurrentDlgPage=ref.CurrentDlgPage;

                if~any(sourceCS.ConfigPrmDlgPosition)
                    if isa(refdlg,'DAStudio.Dialog')
                        offset=[20,20];
                        position=refdlg.position+[offset,0,0];
                        sourceCS.ConfigPrmDlgPosition=configset.util.rectMatlab2Udd(position);
                    end
                end
            end
            sourceCS.openDialog;
            if~isempty(dlg)

                sourceCS.getDialogController.ParentDialog=dlg;
            end
        end
        out=sourceCS.getDialogHandle;
    end
