function configure(obj,hDI)





    configure@hwcli.base.WorkflowBase(obj,hDI);

    if(obj.RunTaskBuildFPGAInTheLoop)
        hDI.setTargetFrequency(hDI.getTargetFrequency);
        hDI.hFilBuildInfo.IPAddress=obj.IPAddress;
        hDI.hFilBuildInfo.MACAddress=obj.MACAddress;
        hDI.hFilBuildInfo.setConnection(obj.Connection);
        hDI.hFilBuildInfo.EnableHWBuffer=obj.EnableDataBufferingOnFPGA;
        hDI.hFilWizardDlg.EnableHWBuffer=obj.EnableDataBufferingOnFPGA;

        hManager=eda.internal.boardmanager.BoardManager.getInstance;
        ConnectionsAvailable=hManager.getBoardObj(hDI.hFilBuildInfo.Board).getFILConnectionOptions;
        FILConnection=cellfun(@(x)x.Name,ConnectionsAvailable,'UniformOutput',false);
        TempInterfaceIdx=find(strcmp(obj.Connection,...
        FILConnection));
        hDI.hFilWizardDlg.ConnectionSelection=TempInterfaceIdx-1;

        fileEntries=hDI.hFilBuildInfo.getFileTypes;
        tmp=strsplit(obj.SourceFiles,';');
        for m=1:numel(tmp)/2
            hDI.hFilWizardDlg.FileTableData{m,1}=tmp{2*m-1};
            filetype.Type='combobox';
            filetype.Entries=fileEntries;
            filetype.Value=hDI.hFilWizardDlg.fileTypeStr2Int(tmp{m*2})-1;
            hDI.hFilWizardDlg.FileTableData{m,2}=filetype;

            hDI.hFilBuildInfo.addSourceFile(...
            tmp{m*2-1},...
            tmp{m*2});
        end
    end

end
