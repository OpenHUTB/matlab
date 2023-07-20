classdef AddSubTypeDialog<handle



    properties
callerSrc
callerDlg
callerRow
availableParentTypes
wantedType
wantedSupertype
    end

    methods
        function this=AddSubTypeDialog(parentSrc,parentDlg,parentRow)
            this.callerSrc=parentSrc;
            this.callerDlg=parentDlg;
            this.callerRow=parentRow;
        end
    end

    methods
        function dlgstruct=getDialogSchema(this,~)

            parentTypeLabel.Type='text';
            parentTypeLabel.Name=getString(message('Slvnv:slreq_objtypes:ParentTypeLabel'));
            parentTypeLabel.RowSpan=[1,1];
            parentTypeLabel.ColSpan=[1,1];

            parentTypeCombo.Type='combobox';
            parentTypeCombo.Name='';
            parentTypeCombo.Tag='ReqSuperType';
            [displayNames,isResolved]=slreq.app.RequirementTypeManager.getAllDisplayNames();
            this.availableParentTypes=displayNames(isResolved);
            placeholderText=getString(message('Slvnv:slreq_objtypes:ParentTypeHint'));
            parentTypeCombo.Entries=[{placeholderText},this.availableParentTypes];
            parentTypeCombo.Values=0:numel(this.availableParentTypes);
            parentTypeCombo.Value=0;



            parentTypeCombo.RowSpan=[1,1];
            parentTypeCombo.ColSpan=[2,2];

            newTypeLabel.Type='text';
            newTypeLabel.Name=getString(message('Slvnv:slreq_objtypes:NewTypeLabel'));
            newTypeLabel.RowSpan=[2,2];
            newTypeLabel.ColSpan=[1,1];

            newTypeEdit.Type='edit';
            newTypeEdit.Name='';
            newTypeEdit.Tag='ReqNewTypeName';
            newTypeEdit.RowSpan=[2,2];
            newTypeEdit.ColSpan=[2,2];

            descriptionLabel.Type='text';
            descriptionLabel.Name=getString(message('Slvnv:slreq:Description'));
            descriptionLabel.RowSpan=[3,3];
            descriptionLabel.ColSpan=[1,1];

            descriptionEdit.Type='edit';
            descriptionEdit.Name='';
            descriptionEdit.Tag='ReqNewTypeDescription';
            descriptionEdit.RowSpan=[3,3];
            descriptionEdit.ColSpan=[2,2];

            panel=struct('Type','group','Name',getString(message('Slvnv:slreq_objtypes:AddSubtypeInstruction')));
            panel.LayoutGrid=[3,2];
            panel.Items={parentTypeLabel,parentTypeCombo,newTypeLabel,newTypeEdit,descriptionLabel,descriptionEdit};

            dlgstruct.DialogTitle=getString(message('Slvnv:slreq_objtypes:AddSubtypeDlgTitle'));
            dlgstruct.StandaloneButtonSet={'OK','Cancel'};
            dlgstruct.ContentsMargins=[5,5,5,5];
            dlgstruct.Items={panel};

            dlgstruct.PreApplyMethod='dlgValidate';
            dlgstruct.PreApplyArgs={'%dialog'};
            dlgstruct.PreApplyArgsDT={'handle'};

            dlgstruct.CloseMethod='dlgCloseMethod';
            dlgstruct.CloseMethodArgs={'%dialog','%closeaction'};
            dlgstruct.CloseMethodArgsDT={'handle','string'};

            dlgstruct.Sticky=true;
            dlgstruct.Geometry=[500,300,510,300];
        end

        function[ok,msg]=dlgValidate(this,dlg)
            this.wantedType='';
            supertypeIdx=dlg.getWidgetValue('ReqSuperType');
            if supertypeIdx==0
                ok=false;
                msg=getString(message('Slvnv:slreq_objtypes:MustSelectParentType'));
                return;
            else
                this.wantedSupertype=this.availableParentTypes{supertypeIdx};
            end
            newTypeName=strtrim(dlg.getWidgetValue('ReqNewTypeName'));
            if isempty(newTypeName)
                ok=false;
                msg=getString(message('Slvnv:slreq_objtypes:MustSpecifyNewTypeName'));
                return;
            elseif this.isNameAlreadyRegistered(newTypeName)
                ok=false;
                msg=getString(message('Slvnv:slreq:SpecifiedTypeExists',newTypeName));
                return;
            else
                this.wantedType=newTypeName;
            end
            ok=true;
            msg='';
        end

        function tf=isNameAlreadyRegistered(~,name)
            registeredTypeNames=slreq.app.RequirementTypeManager.getAllDisplayNames();
            tf=any(strcmp(registeredTypeNames,name));
        end

        function dlgCloseMethod(this,dlg,actionStr)
            if strcmpi(actionStr,'ok')
                rmiut.progressBarFcn('set',0.1,getString(message('Slvnv:slreq_objtypes:ProgressRegisteringType',this.wantedType)));
                this.registerSubtype(dlg);
                rmiut.progressBarFcn('set',0.9,getString(message('Slvnv:slreq_objtypes:ProgressUpdatingDialog')));
                this.selectNewTypeInCallerWidget();
                rmiut.progressBarFcn('delete');
            end
        end

        function registerSubtype(this,dlg)
            newTypeDescription=dlg.getWidgetValue('ReqNewTypeDescription');
            if isempty(newTypeDescription)
                newTypeDescription=getString(message('Slvnv:slreq_objtypes:DefaultDescription',this.wantedSupertype));
            end
            supertypeId=slreq.app.RequirementTypeManager.getIdentifierFromDisplayName(this.wantedSupertype);
            slreq.internal.registerRequirementType(this.wantedType,newTypeDescription,supertypeId);
        end

        function selectNewTypeInCallerWidget(this)
            this.callerDlg.refresh();


            this.callerSrc.updateMapping(this.callerRow,this.wantedType);
            this.callerDlg.refresh();
        end
    end
end
