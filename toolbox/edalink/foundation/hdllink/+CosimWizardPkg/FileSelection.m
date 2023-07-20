

classdef FileSelection<CosimWizardPkg.StepBase
    methods
        function obj=FileSelection(Wizard)
            obj=obj@CosimWizardPkg.StepBase(Wizard);
        end
        function WidgetGroup=getDialogSchema(this)

            BrowseFile.Name='Add';
            BrowseFile.Tag='edaBrowseHdlFile';
            BrowseFile.Type='pushbutton';
            BrowseFile.ObjectMethod='onBrowseHdlFile';
            BrowseFile.MethodArgs={'%dialog','',''};
            BrowseFile.ArgDataTypes={'handle','mxArray','mxArray'};
            BrowseFile.RowSpan=[2,2];
            BrowseFile.ColSpan=[6,6];
            BrowseFile.Enabled=true;


            RemoveFile.Name='Remove';
            RemoveFile.Tag='edaRemoveHdlFile';
            RemoveFile.Type='pushbutton';
            RemoveFile.ObjectMethod='onRemoveHdlFile';
            RemoveFile.MethodArgs={'%dialog'};
            RemoveFile.ArgDataTypes={'handle'};
            RemoveFile.RowSpan=[3,3];
            RemoveFile.ColSpan=[6,6];
            RemoveFile.Enabled=true;

            MoveUp.Name='Up';
            MoveUp.Tag='edaMoveUp';
            MoveUp.Type='pushbutton';
            MoveUp.ObjectMethod='onMoveFileUp';
            MoveUp.MethodArgs={'%dialog'};
            MoveUp.ArgDataTypes={'handle'};
            MoveUp.RowSpan=[4,4];
            MoveUp.ColSpan=[6,6];
            MoveUp.Enabled=true;

            MoveDown.Name='Down';
            MoveDown.Tag='edaMoveDown';
            MoveDown.Type='pushbutton';
            MoveDown.ObjectMethod='onMoveFileDown';
            MoveDown.MethodArgs={'%dialog'};
            MoveDown.ArgDataTypes={'handle'};
            MoveDown.RowSpan=[5,5];
            MoveDown.ColSpan=[6,6];
            MoveDown.Enabled=true;

            FileTableTitle.Name='Source Files:';
            FileTableTitle.Tag='edaFileTableTitle';
            FileTableTitle.Type='text';
            FileTableTitle.RowSpan=[1,1];
            FileTableTitle.ColSpan=[1,2];


            FileList.Tag='edaFileList';
            FileList.Type='table';
            FileList.RowSpan=[2,10];
            FileList.ColSpan=[1,5];
            FileList.Size=size(this.Wizard.FileTable);
            FileList.Data=this.Wizard.FileTable;
            FileList.HeaderVisibility=[0,1];
            FileList.ColHeader={'HDL File','File Type'};
            FileList.RowHeader={};
            FileList.Enabled=true;
            FileList.Editable=true;
            FileList.Mode=1;
            FileList.FontFamily='Courier';
            FileList.ReadOnlyColumns=0;


            tableSize=size(this.Wizard.FileTable);
            if(tableSize(1))
                maxFilePath=0;
                for m=1:tableSize(1)
                    currentFilePath=length(this.Wizard.FileTable{m,1});
                    if(maxFilePath<currentFilePath)
                        maxFilePath=currentFilePath;
                    end
                end
                maxFilePath=max(maxFilePath,40);
                FileList.ColumnCharacterWidth=[maxFilePath+1,20];
            else
                FileList.ColumnCharacterWidth=[30,15];
            end


            WidgetGroup.LayoutGrid=[10,6];
            WidgetGroup.RowStretch=[0,ones(1,9)];
            WidgetGroup.ColStretch=[1,1,1,1,1,1];
            WidgetGroup.Items={FileTableTitle,BrowseFile,RemoveFile,MoveUp,MoveDown,FileList};


            this.Wizard.UserData.CurrentStep=2;
        end
        function EnterStep(this,~)
            [row,~]=size(this.Wizard.UserData.HdlFiles);

            this.Wizard.FileTable=cell(row,2);

            for m=1:row
                this.Wizard.FileTable{m,1}=this.Wizard.UserData.HdlFiles{m,1};
                this.Wizard.FileTable{m,2}=l_CreateFileTypeComboBox(...
                this.Wizard.UserData.HdlFiles{m,2},this.Wizard.UserData.FileTypes);
            end

            function widget=l_CreateFileTypeComboBox(filetype,entries)
                widget.Type='combobox';
                widget.Entries=entries;
                widget.Enabled=true;
                widget.Value=filetype;
            end

            return;
        end
        function onBack(this,dlg)
            l_updateSourceFileList(this.Wizard,dlg);
            this.Wizard.NextStepID=1;
        end
        function onNext(this,dlg)
            [row,~]=size(this.Wizard.FileTable);
            assert(row>0,...
            message('HDLLink:CosimWizard:NoFileSpecified'));

            l_updateSourceFileList(this.Wizard,dlg);

            genCompileCommand(this.Wizard.UserData);
            this.Wizard.CompileCmd=this.Wizard.UserData.GeneratedCompileCmd;

            this.Wizard.NextStepID=3;
        end
        function Description=getDescription(~)

            Description=...
            ['Add all VHDL, Verilog, and/or script files to be used in cosimulation '...
            ,'to the following table. If the file type cannot be automatically detected '...
            ,'or the detection result is incorrect, specify the correct file type in the '...
            ,'table. If possible, we will determine the compilation order automatically using '...
            ,'HDL simulator provided functionality. Then the HDL files can be added in any order.'];
        end
    end
end

function l_updateSourceFileList(Wizard,dlg)
    [row,~]=size(Wizard.FileTable);
    Wizard.UserData.HdlFiles=cell(row,2);
    for m=1:row
        strFileType=Wizard.getTableItemValue(dlg,'edaFileList',m-1,1);
        intFileType=l_getFileType(strFileType);
        Wizard.UserData.HdlFiles{m,1}=Wizard.getTableItemValue(dlg,'edaFileList',m-1,0);
        Wizard.UserData.HdlFiles{m,2}=intFileType;
    end
end

function intType=l_getFileType(strType)
    switch(strType)
    case 'Verilog'
        intType=0;
    case 'VHDL'
        intType=1;
    case{'ModelSim macro file','Shell script'}
        intType=2;
    otherwise
        error(message('HDLLink:CosimWizard:UnknownFile'));
    end
end


