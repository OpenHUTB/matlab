function WidgetGroup=getSrcFileWidgets(this)




    if this.IsInHDLWA
        SrcFileTxt.Name='Specify additional source files for the HDL design';
    else
        SrcFileTxt.Name=this.getCatalogMsgStr('SrcFile_Text');
    end
    SrcFileTxt.Tag='edaSrcFileTxt';
    SrcFileTxt.Type='text';
    SrcFileTxt.RowSpan=[1,1];
    SrcFileTxt.ColSpan=[1,1];


    tableSize=size(this.FileTableData);
    maxFileNameLength=0;
    for m=1:tableSize(1)
        maxFileNameLength=max(maxFileNameLength,length(this.FileTableData{m,1}));
    end


    if(isunix)
        maxColumnCharWidth=48;
    else
        maxColumnCharWidth=41;
    end

    fileColumnCharacterWidth=min(max(maxFileNameLength+1,30),maxColumnCharWidth);


    ShowFullPath.Name=this.getCatalogMsgStr('ShowFullFilePath_CheckBox');
    ShowFullPath.Tag='edaShowFullPath';
    ShowFullPath.Type='checkbox';
    ShowFullPath.RowSpan=[1,1];
    ShowFullPath.ColSpan=[6,7];
    ShowFullPath.Source=this;
    ShowFullPath.ObjectProperty='ShowFullFilePath';
    ShowFullPath.ObjectMethod='onChangeShowFullPath';
    ShowFullPath.MethodArgs={'%dialog'};
    ShowFullPath.ArgDataTypes={'handle'};
    ShowFullPath.Mode=true;


    SrcFileTbl.Tag='edaSourceFiles';
    SrcFileTbl.Type='table';
    SrcFileTbl.RowSpan=[2,9];
    SrcFileTbl.ColSpan=[1,6];

    if this.IsInHDLWA
        SrcFileTbl.Size=[tableSize(1),2];
        SrcFileTbl.Data=this.FileTableData(:,1:2);
        SrcFileTbl.HeaderVisibility=[0,1];
        SrcFileTbl.ColHeader={this.getCatalogMsgStr('FileName_ColHeader'),...
        this.getCatalogMsgStr('FileType_ColHeader')};
        SrcFileTbl.ColumnCharacterWidth=[fileColumnCharacterWidth,12];
        SrcFileTbl.ValueChangedCallback=@l_hdlwaTableValueChangeCb;
    else
        SrcFileTbl.Size=tableSize;
        SrcFileTbl.Data=this.FileTableData;
        SrcFileTbl.HeaderVisibility=[0,1];
        SrcFileTbl.ColHeader={this.getCatalogMsgStr('FileName_ColHeader'),...
        this.getCatalogMsgStr('FileType_ColHeader'),...
        this.getCatalogMsgStr('TopLevel_ColHeader')};
        SrcFileTbl.ColumnCharacterWidth=[fileColumnCharacterWidth,12,12];
        SrcFileTbl.ValueChangedCallback=@l_tableValueChangeCb;
    end


    SrcFileTbl.RowHeader={};
    SrcFileTbl.ColumnHeaderHeight=2;
    SrcFileTbl.Enabled=true;
    SrcFileTbl.Editable=true;
    SrcFileTbl.Mode=1;
    SrcFileTbl.FontFamily='Courier';
    SrcFileTbl.ReadOnlyColumns=0;


    AddButton.Name=this.getCatalogMsgStr('Add_Button');
    AddButton.Tag='edaAddFileBtn';
    AddButton.Type='pushbutton';
    AddButton.Source=this;
    AddButton.ObjectMethod='onAddFile';
    AddButton.MethodArgs={'%dialog'};
    AddButton.ArgDataTypes={'handle'};
    AddButton.RowSpan=[2,2];
    AddButton.ColSpan=[7,7];
    AddButton.Enabled=true;

    RemoveButton.Name=this.getCatalogMsgStr('Remove_Button');
    RemoveButton.Tag='edaRemoveFileBtn';
    RemoveButton.Type='pushbutton';
    RemoveButton.Source=this;
    RemoveButton.ObjectMethod='onRemoveFile';
    RemoveButton.MethodArgs={'%dialog'};
    RemoveButton.ArgDataTypes={'handle'};
    RemoveButton.RowSpan=[3,3];
    RemoveButton.ColSpan=[7,7];
    RemoveButton.Enabled=(SrcFileTbl.Size(1)>0);

    UpButton.Name=this.getCatalogMsgStr('Up_Button');
    UpButton.Tag='edaUpFileBtn';
    UpButton.Type='pushbutton';
    UpButton.Source=this;
    UpButton.ObjectMethod='onMoveUpFile';
    UpButton.MethodArgs={'%dialog'};
    UpButton.ArgDataTypes={'handle'};
    UpButton.RowSpan=[4,4];
    UpButton.ColSpan=[7,7];
    UpButton.Enabled=true;

    DownButton.Name=this.getCatalogMsgStr('Down_Button');
    DownButton.Tag='edaDownFileBtn';
    DownButton.Type='pushbutton';
    DownButton.Source=this;
    DownButton.ObjectMethod='onMoveDownFile';
    DownButton.MethodArgs={'%dialog'};
    DownButton.ArgDataTypes={'handle'};
    DownButton.RowSpan=[5,5];
    DownButton.ColSpan=[7,7];
    DownButton.Enabled=true;

    ModuleName.Name=this.getCatalogMsgStr('TopLevelModule_Edit');
    ModuleName.Tag='edaTopModule';
    ModuleName.Type='edit';
    ModuleName.RowSpan=[10,10];
    ModuleName.ColSpan=[1,4];
    ModuleName.Enabled=true;
    ModuleName.Mode=true;
    ModuleName.Visible=~this.IsInHDLWA;
    ModuleName.ObjectProperty='TopModuleName';
    ModuleName.ObjectMethod='onChangeModuleName';



    if this.IsInHDLWA
        WidgetGroup.Type='group';
        WidgetGroup.Name='Action';
        WidgetGroup.Flat=false;
        WidgetGroup.LayoutGrid=[9,7];
        WidgetGroup.RowStretch=ones(1,9);
        WidgetGroup.Items={ShowFullPath,SrcFileTbl,AddButton,RemoveButton,UpButton,DownButton};
    else
        WidgetGroup=this.getWidgetGroup;
        WidgetGroup.LayoutGrid=[10,7];
        WidgetGroup.RowStretch=ones(1,10);
        WidgetGroup.Items={SrcFileTxt,ShowFullPath,SrcFileTbl,AddButton,RemoveButton,ModuleName,UpButton,DownButton};
    end
    WidgetGroup.Tag='edaWidgetGroupSrcFile';
    WidgetGroup.ColStretch=[1,1,1,1,1,1,0];

end

function l_hdlwaTableValueChangeCb(dlg,row,~,value)

    task=Advisor.Utils.convertMCOS(dlg.getSource);
    mdladvObj=task.MAObj;
    system=mdladvObj.System;
    hModel=bdroot(system);
    hDriver=get_param(hModel,'HDLCoder');
    hDI=hDriver.DownstreamIntegrationDriver;

    h=hDI.hFilWizardDlg;

    strValue=h.fileTypeInt2Str(value);

    h.BuildInfo.setSourceFileType(row+1,strValue);


    h.FileTableData{row+1,2}.Value=value;
end

function l_tableValueChangeCb(dlg,row,col,value)
    src=dlg.getSource;
    if src.IsInHDLWA
        h=Advisor.Utils.convertMCOS(dlg.getSource);
    else
        h=src;
    end

    h.Status='';
    if(col==1)
        strValue=h.fileTypeInt2Str(value);

        h.BuildInfo.setSourceFileType(row+1,strValue);


        h.FileTableData{row+1,2}.Value=value;

        if(~h.BuildInfo.isEligibleTopLevel(strValue))
            h.FileTableData{row+1,3}.Enabled=false;
            h.FileTableData{row+1,3}.Value=false;
        else
            h.FileTableData{row+1,3}.Enabled=true;
        end
    elseif(col==2)
        if(value)

            if(h.BuildInfo.TopLevelIndex>0)
                h.FileTableData{h.BuildInfo.TopLevelIndex,3}.Value=false;
            end

            h.BuildInfo.setTopLevelSourceFile(row+1);
            h.FileTableData{row+1,3}.Value=true;


            if(isempty(h.TopModuleName))
                h.HasChangedTopModuleName=false;
            end
            if(~h.HasChangedTopModuleName)
                [~,moduleName,~]=fileparts(h.FileTableData{row+1,1});


                if(h.BuildInfo.isValidHDLName(moduleName))
                    h.TopModuleName=moduleName;

                end
            end
        else
            h.BuildInfo.unsetTopLevelSourceFile;
            h.FileTableData{row+1,3}.Value=false;
        end
    end

end