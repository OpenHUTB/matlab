classdef newFilterView<handle
    properties(SetObservable)
        reqSets;
        reqSetNames;


        storage='User';
        name='';
        reqSet='';
    end

    methods
        function varType=getPropDataType(this,varName)
            switch varName
            case{'storage','reqSet'}
                varType='enum';
            otherwise
                varType='string';
            end
        end

        function allowedVals=getPropAllowedValues(this,propName)
            allowedVals={};
            switch propName
            case 'storage'
                if isempty(this.reqSets)
                    allowedVals={'User'};
                else
                    allowedVals={'User','Requirement Set'};
                end
            case 'reqSet'
                allowedVals=this.reqSetNames;
            end
        end
    end

    methods
        function this=newFilterView()
            this.reqSets=slreq.find('type','ReqSet');
            for i=1:length(this.reqSets)
                this.reqSetNames{end+1}=this.reqSets(i).Name;
            end
        end

        function dlgstruct=getDialogSchema(this,dlg)
            dlgstruct.DialogTitle=getString(message('Slvnv:slreq_import:ImportingRequirements'));
            if ismac


                dlgstruct.Sticky=false;
            else
                dlgstruct.Sticky=true;
            end

            dlgstruct.DialogTag='SlreqNewFilterViewDlg';
            dlgstruct.CloseMethod='SlreqImportDlg_Cancel_callback';
            dlgstruct.CloseMethodArgs={'%dialog'};
            dlgstruct.CloseMethodArgsDT={'handle'};

            source=this.sourceGroup();
            if strcmp(this.storage,'User')
                dlgstruct.Items=source(:)';
                dlgstruct.LayoutGrid=[2,2];

            else
                rsets=this.reqSetGroup();
                dlgstruct.Items=[source(:)',rsets(:)'];
                dlgstruct.LayoutGrid=[3,2];
            end

            dlgstruct.StandaloneButtonSet={'OK','Cancel'};

            dlgstruct.CloseMethod='dlgCloseMethod';
            dlgstruct.CloseMethodArgs={'%dialog','%closeaction'};
            dlgstruct.CloseMethodArgsDT={'handle','string'};



        end

        function dlgCloseMethod(this,dlg,actionStr)

            if strcmp(actionStr,'ok')&&~isempty(this.name)
                mgr=slreq.app.MainManager.getInstance;
                vm=mgr.viewManager;


                if false
                    warndlg('name already taken','duplicate name dialog','modal');
                    n=slreq.gui.newFilterView;
                    DAStudio.Dialog(n);
                    return;
                end

                switch this.storage
                case 'User'
                    vm.createView(this.name);
                case 'Requirement Set'
                    rset=slreq.find('type','ReqSet','Name',this.reqSet);
                    vm.createView(this.name,slreq.gui.View.SET,rset.Filename);
                end
            end
        end
    end

    methods(Access=private)
        function widgets=sourceGroup(this)

            nameEdit=struct('Type','edit','RowSpan',[1,1],'ColSpan',[1,2]);
            nameEdit.Tag='nameEdit';
            nameEdit.Name='view name';
            nameEdit.ObjectProperty='name';
            nameEdit.Mode=1;

            storageCombo=struct('Type','combobox','RowSpan',[2,2],'ColSpan',[1,2]);
            storageCombo.ObjectProperty='storage';
            storageCombo.DialogRefresh=1;
            storageCombo.Mode=1;

            widgets={nameEdit,storageCombo};
        end

        function widgets=reqSetGroup(this)
            rsetCombo=struct('Type','combobox','RowSpan',[3,3],'ColSpan',[1,2]);
            rsetCombo.Name='Select requirement set';
            rsetCombo.Tag='reqsetCombo';
            rsetCombo.Mode=1;
            rsetCombo.ObjectProperty='reqSet';

            widgets={rsetCombo};
        end
    end
end