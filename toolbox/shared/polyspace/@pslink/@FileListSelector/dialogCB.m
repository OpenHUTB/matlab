function dialogCB(this,action,hDlg)




    switch lower(action)
    case 'addfile'
        [newFiles,filePath]=uigetfile({'*.c','C Source Files (*.c)';...
        '*.*','All Files (*.*)'},...
        pslinkprivate('pslinkMessage','get','pslink:fileSelectorSelectFiles'),'MultiSelect','on');

        if~isempty(newFiles)&&~isequal(newFiles,0)

            newFiles=cellstr(newFiles);
            for ii=1:numel(newFiles)
                newFiles{ii}=fullfile(filePath,newFiles{ii});
            end


            currentFiles=this.AdditionalFileList;
            currentFiles=RTW.unique([currentFiles(:)',newFiles(:)']);


            this.AdditionalFileList=currentFiles(:);
            hDlg.refresh();
        end

    case 'removefile'
        fileIdx=hDlg.getWidgetValue('_pslink_additional_files_list_tag');
        if~isempty(fileIdx)&&all(fileIdx>=0)
            this.AdditionalFileList(fileIdx+1)=[];
            hDlg.refresh();
        end

    case 'removeallfiles'
        ok=questdlg(pslinkprivate('pslinkMessage','get','pslink:fileSelectorRemoveFiles'),pslinkprivate('pslinkMessage','get','pslink:fileSelectorRemoveAll'),'OK','Cancel','OK');
        if strcmpi(ok,'ok')
            this.AdditionalFileList={};
            hDlg.refresh();
        end

    otherwise


    end


