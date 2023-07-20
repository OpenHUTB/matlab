classdef saveFilterView<handle
    properties
        viewNames;
        viewMgr;
    end

    methods
        function this=saveFilterView
            this.viewMgr=slreq.app.MainManager.getInstance.viewManager;
            views=this.viewMgr.getViews;
            this.viewNames={''};
            for i=1:length(views)
                if~views(i).isVanillaView
                    this.viewNames{end+1}=views(i).name;
                end
            end
        end

        function dlgstruct=getDialogSchema(this,dlg)
            dlgstruct.DialogTitle=getString(message('Slvnv:slreq:FilterViewSaveDialogTitle'));
            dlgstruct.DialogTag='SlreqNewFilterViewDlg';

            dlgstruct.StandaloneButtonSet={'OK','Cancel'};

            dlgstruct.CloseMethod='dlgCloseMethod';
            dlgstruct.CloseMethodArgs={'%dialog','%closeaction'};
            dlgstruct.CloseMethodArgsDT={'handle','string'};

            label.Type='text';
            label.Name='Enter a name for the view';

            viewsCombo.Type='combobox';
            viewsCombo.Tag='viewsCombo';
            viewsCombo.Editable=true;
            viewsCombo.Entries=this.viewNames;

            dlgstruct.Items={label,viewsCombo};
        end

        function dlgCloseMethod(this,dlg,actionStr)
            name=dlg.getWidgetValue('viewsCombo');
            if strcmp(actionStr,'ok')&&~isempty(name)
                if any(strcmp(this.viewNames,name))
                    ans=questdlg(['view ',name,' already exists, overwrite?'],...
                    'Slvnv:slreq:FilterViewSaveDialogTitle',...
                    'Yes','No');
                    if strcmp(ans,'Yes')
                        cur=this.viewMgr.getCurrentView;
                        v=this.viewMgr.getView(name);
                        if cur==v
                            this.viewMgr.saveUserViews(v);
                        else
                            v.takeView(cur,true);
                            this.viewMgr.saveUserViews(v);
                        end
                    end
                else

                    v=this.viewMgr.createView(name);
                    v.takeView(this.viewMgr.getCurrentView,true);
                    this.viewMgr.saveUserViews(v);
                end
            end
        end

    end
end
