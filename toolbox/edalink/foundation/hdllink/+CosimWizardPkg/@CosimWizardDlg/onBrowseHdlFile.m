function onBrowseHdlFile(this,dialog,filenames,pathname)




    if~isempty(dialog)
        switch this.UserData.Simulator
        case 'ModelSim'
            scriptname='ModelSim macro file';
            scriptspec={'*.do',[scriptname,' (*.do)']};
        otherwise
            scriptname='Shell script';
            scriptspec={'*.sh',[scriptname,' (*.sh)']};
        end

        filterspec={'*.v;*.sv;*.vhd','HDL files (*.v,*.sv,*.vhd)';...
        scriptspec{:};...
        '*.*','All files (*.*)'};

        onCleanupObj=CosimWizardPkg.disableButtonSet(this,dialog);
        [filenames,pathname,index]=uigetfile(filterspec,'Select HDL Source Files','MultiSelect','on');
        delete(onCleanupObj);
    else
        index=1;
    end

    if(index)
        if(~iscell(filenames))
            filenames={filenames};
            newRows=cell(1,2);
        else
            newRows=cell(numel(filenames),2);
        end
        for m=1:numel(filenames)
            filetype=l_getFileType(filenames{m});
            newRows{m,1}=fullfile(pathname,filenames{m});
            newRows{m,2}=l_CreateFileTypeComboBox(filetype,this.UserData.FileTypes);
        end
        this.FileTable=[this.FileTable;newRows];
    end

    if~isempty(dialog)
        dialog.refresh;
    end
end

function widget=l_CreateFileTypeComboBox(filetype,entries)
    widget.Type='combobox';
    widget.Entries=entries;
    widget.Enabled=true;
    widget.Value=filetype;
end

function type=l_getFileType(filename)

    [~,~,ext]=fileparts(filename);
    if strcmpi(ext,'.v')||strcmpi(ext,'.sv')
        type=0;
    elseif(strcmpi(ext,'.vhd'))
        type=1;
    elseif(strcmpi(ext,'.do')||strcmpi(ext,'.sh'))
        type=2;
    else
        type=3;
    end
end



