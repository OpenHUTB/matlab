classdef DialogSelectRequirementSet<handle



    properties(SetObservable=true)
        items;
        callerDlg=[];
    end

    methods

        function this=DialogSelectRequirementSet(items)
            this.callerDlg=ReqMgr.activeDlgUtil();
            this.items=items';
        end

        function dlgStruct=getDialogSchema(this)

            lbl.Type='text';
            lbl.Name=getString(message('Slvnv:slreq:SelectRequirementSetPlease'));

            cmb.Type='combobox';
            cmb.Name='';
            cmb.Tag='ItemSelectionCombo';
            cmb.ObjectProperty='projectIdx';
            cmb.Entries=[{...
            getString(message('Slvnv:slreq:SelectFromListOrBrowseToFile'))};...
            this.items;...
            {getString(message('Slvnv:slreq:BrowseToFile','*.slreqx'))}];
            cmb.ObjectMethod='cmbSelectionCallback';
            cmb.MethodArgs={'%dialog'};
            cmb.ArgDataTypes={'handle'};

            dlgStruct.DialogTitle=getString(message('Slvnv:slreq:SelectRequirementSet'));
            dlgStruct.DialogTag='ReqSetSelectorDialog';
            dlgStruct.LayoutGrid=[2,1];
            dlgStruct.Items={lbl,cmb};
            dlgStruct.StandaloneButtonSet={'OK','Cancel'};
            dlgStruct.PreApplyCallback='preApplyCallback';
            dlgStruct.PreApplyArgs={this,'%dialog'};
            dlgStruct.Sticky=true;

        end
    end



    methods(Access=public,Hidden=true)

        function cmbSelectionCallback(this,dlg)
            val=dlg.getWidgetValue('ItemSelectionCombo');
            if val>numel(this.items)



                [filename,pathname]=uigetfile('*.slreqx',...
                getString(message('Slvnv:slreq:SelectTheRequirementSetFile')));
                if~isequal(filename,0)

                    selection=fullfile(pathname,filename);

                    if isempty(slreq.utils.loadReqSet(selection))
                        slreq.utils.loadReqSet(selection);
                    end
                    parentDlgH=this.callerDlg;
                    if~isempty(parentDlgH)
                        parentDlgH.setWidgetValue('docEdit',selection);
                        parentSrc=parentDlgH.getSource;
                        parentSrc.changeDocItem(parentDlgH);
                    end

                    this.delete;
                end
            end
        end

        function[isValid,msg]=preApplyCallback(this,dlg)
            idx=dlg.getWidgetValue('ItemSelectionCombo');
            isValid=(idx>0);
            if isValid
                msg='';
                selection=dlg.getComboBoxText('ItemSelectionCombo');


                parentDlgH=this.callerDlg;
                if~isempty(parentDlgH)
                    parentDlgH.setWidgetValue('docEdit',selection);
                    parentSrc=parentDlgH.getSource;
                    parentSrc.changeDocItem(parentDlgH);
                end
            else
                msg=getString(message('Slvnv:slreq:PleaseMakeAValidSelection'));
            end
        end

    end
end