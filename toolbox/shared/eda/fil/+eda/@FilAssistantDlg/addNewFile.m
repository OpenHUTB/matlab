function addNewFile(this,filename,filetypeint,filetypeenum)




    newRow=cell(1,3);
    newRow{1}=filename;
    newRow{2}=l_CreateFileTypeComboBox(filetypeint,filetypeenum);
    filetypestr=filetypeenum{filetypeint+1};
    EnableCheckBox=this.BuildInfo.isEligibleTopLevel(filetypestr);
    newRow{3}=l_CreateTopLevelCheckBox(EnableCheckBox);
    this.FileTableData=[this.FileTableData;newRow];

end

function widget=l_CreateFileTypeComboBox(filetype,entries)
    widget.Type='combobox';
    widget.Entries=entries;
    widget.Enabled=true;
    widget.Value=filetype;
end

function widget=l_CreateTopLevelCheckBox(Enabled)
    widget.Type='checkbox';
    widget.Enabled=Enabled;
    widget.Value=false;
end