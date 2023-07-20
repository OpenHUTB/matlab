

classdef ManageProfileDialog<handle
    properties(Constant)
        ProfileTableTag='ProfileTable';
    end
    properties
profiles
linkReqSet
    end
    methods
        function obj=ManageProfileDialog(linkReqSet)
            obj.linkReqSet=linkReqSet;
        end
        function dlg=getDialogSchema(obj)
            panel=struct('Type','panel','LayoutGrid',[3,1],'RowStretch',[0,0,1]);
            panel.Items={};


            instructionPanel.Type='text';
            instructionPanel.Name=getString(message('Slvnv:slreq:ManageProfileInstruction'));
            instructionPanel.RowSpan=[1,1];
            instructionPanel.ColSpan=[1,1];
            instructionPanel.Alignment=2;
            instructionPanel.Tag='ManageInstruction';
            panel.Items{end+1}=instructionPanel;


            obj.profiles=obj.linkReqSet.dataModelObj.getAllProfiles().toArray();
            numProfiles=numel(obj.profiles);
            profileTable=struct('Type','table','Name','','Size',[numProfiles,2]);
            profileTable.ColHeader={getString(message('Slvnv:slreq:ManageProfileTableColName')),...
            getString(message('Slvnv:slreq:ManageProfileTableColLinkedTo'))};
            profileTable.RowSpan=[2,2];
            profileTable.ColSpan=[1,1];
            profileTable.ColumnCharacterWidth=[20,20];
            profileTable.Tag=obj.ProfileTableTag;
            tableData=cell(numProfiles,2);
            for i=1:numProfiles
                [~,profName,~]=fileparts(obj.profiles{i});
                tableData{i,1}=profName;
                if isa(obj.linkReqSet,'slreq.das.LinkSet')
                    tableData{i,2}=obj.linkReqSet.Label;
                else
                    tableData{i,2}=obj.linkReqSet.Name;
                end
            end
            profileTable.Data=tableData;
            profileTable.SelectionChangedCallback=@obj.SelectionChangedCallback;
            panel.Items{end+1}=profileTable;


            actionPanel=struct('Type','panel','LayoutGrid',[1,1]);
            actionPanel.RowSpan=[2,2];
            importButton.Name=getString(message('Slvnv:slreq:ManageProfileImportBtn'));
            importButton.Type='pushbutton';
            importButton.RowSpan=[1,1];
            importButton.ColSpan=[1,1];
            importButton.ObjectMethod='importProfile';
            importButton.MethodArgs={'%dialog'};
            importButton.ArgDataTypes={'handle'};
            importButton.Enabled=true;

            removeButton.Name=getString(message('Slvnv:slreq:ManageProfileRemoveBtn'));
            removeButton.Type='pushbutton';
            removeButton.Tag='manageProfileRemoveProfileBtn';
            removeButton.RowSpan=[1,1];
            removeButton.ColSpan=[2,2];
            removeButton.ObjectMethod='removeProfile';
            removeButton.MethodArgs={'%dialog'};
            removeButton.ArgDataTypes={'handle'};
            removeButton.Enabled=false;

            actionPanel.Items={importButton,removeButton};
            panel.Items{end+1}=actionPanel;

            helpButton.Name=getString(message('Slvnv:slreq:ExportDialogHelp'));
            helpButton.Tag='ExportDlg_Help';
            helpButton.Type='pushbutton';
            helpButton.RowSpan=[1,1];
            helpButton.ColSpan=[5,5];
            helpButton.ObjectMethod='ExportDlg_Help_callback';
            helpButton.MethodArgs={'%dialog'};
            helpButton.ArgDataTypes={'handle'};
            helpButton.Enabled=true;

            cancelButton.Name=getString(message('Slvnv:slreq_import:Cancel'));
            cancelButton.Tag='closeDialog';
            cancelButton.Type='pushbutton';
            cancelButton.RowSpan=[1,1];
            cancelButton.ColSpan=[1,4];
            cancelButton.ObjectMethod='closeDialog';
            cancelButton.MethodArgs={'%dialog'};
            cancelButton.ArgDataTypes={'handle'};
            cancelButton.Enabled=true;


            stdBtns.Type='panel';
            stdBtns.Name='';
            stdBtns.LayoutGrid=[1,5];
            stdBtns.Items={helpButton,cancelButton};

            dlg.DialogTitle=getString(message('Slvnv:slreq:ManageProfileDialogTitle'));
            dlg.DialogTag='ManageProfileDialog';
            dlg.StandaloneButtonSet=stdBtns;
            dlg.IsScrollable=false;
            dlg.Items={panel};
        end

        function importProfile(obj,dlg)

            filepath=[];
            [filename,pathname]=uigetfile('*.xml',...
            getString(message('Slvnv:slreq:SelectTheRequirementSetFile')));
            if~isequal(filename,0)
                filepath=fullfile(pathname,filename);
            end

            if~isempty(filepath)
                obj.linkReqSet.dataModelObj.importProfile(filepath);
                dlg.refresh();
            end
        end

        function closeDialog(~,dlg)
            dlg.delete();
        end

        function removeProfile(obj,dlg)
            rowSel=dlg.getSelectedTableRow(obj.ProfileTableTag);
            profile=obj.profiles{rowSel+1};
            obj.linkReqSet.dataModelObj.removeProfile(profile);

            dlg.refresh();
        end

        function SelectionChangedCallback(obj,dlg,~)
            rowSel=dlg.getSelectedTableRow(obj.ProfileTableTag);

            if rowSel>=0&&rowSel<length(obj.profiles)
                dlg.setEnabled('manageProfileRemoveProfileBtn',true);
            else
                dlg.setEnabled('manageProfileRemoveProfileBtn',false);
            end
        end

        function ExportDlg_Help_callback(~,~)
            helpview(fullfile(docroot,'slrequirements','helptargets.map'),'ManageProfile');
        end
    end
end

