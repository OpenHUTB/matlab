function uploadTarget(h,val)%#ok




    if h.ThisDlg.hasUnappliedChanges
        hParent=get(h,'parentSrc');

        if~isempty(hParent)&&isa(hParent,'Simulink.ConfigSet')













            filesIdx=get(h,'tlcfiles_selected');
            if filesIdx>-1
                tlcfiles=get(h,'tlcfiles');
                selected=tlcfiles(filesIdx);

                settings.TemplateMakefile=selected.tmf;
                settings.MakeCommand=selected.makeCmd;
                settings.Description=selected.description;
                settings.PushNag=true;
                codertarget.utils.getOrSetSTFInfo(settings);
                oldTarget=hParent.getComponent('Code Generation').getComponent('Target');





                h.selectedSettings=settings;
                hDlg=get(h,'ParentDlg');
                newtlc=selected.shortName;
                if~isempty(hDlg)
                    dlgSrc=hDlg.getSource;

                    oldtlc=hParent.getProp('SystemTargetFile');



                    if~strcmp(oldtlc,newtlc)
                        dlg=ConfigSet.DDGWrapper(hDlg);
                        dlg.dirtyWidget('SystemTargetFile',true);
                        dlg.setWidgetValue('Tag_ConfigSet_RTW_SystemTargetFile',newtlc);
                    end



                    dlgSrc.removeError('SystemTargetFile');


                    hParent.switchTarget(newtlc,settings);

                else
                    hParent.switchTarget(newtlc,settings);
                end
                newTarget=hParent.getComponent('Code Generation').getComponent('Target');

                if~strcmp(class(newTarget),'Simulink.CustomTargetCC')&&newTarget.isa(class(oldTarget))%#ok<STISA>
                    if ismethod(newTarget,'compatibleWith')&&newTarget.compatibleWith(oldTarget)
                        newTarget.assignFrom(oldTarget,true);
                    end
                end

                if~isempty(hDlg)

                    web=hDlg.getDialogSource;
                    web.enableApplyButton(true);
                end
            end
        end
    end
