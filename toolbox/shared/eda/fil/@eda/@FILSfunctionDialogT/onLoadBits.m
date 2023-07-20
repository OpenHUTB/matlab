function onLoadBits(this,dialogH)




    if(dialogH.hasUnappliedChanges())
        errordlg('Dialog has unapplied changes.  Apply changes and click ''Load'' again.',...
        'Unapplied changes','modal');
        return;
    end
    h=eda.FILLoadBitstreamDialogT;
    h.updateInfo(...
    this.dialogState.bitstreamFile,...
    this.buildInfo.Board,...
    this.buildInfo.FPGAPartInfo);
    h.updateStatus('Loading FPGA programming file.  Depending on the size of the design, this could take several minutes...');

    dlg=DAStudio.Dialog(h);

    try
        if~isempty(this.params.programFPGAOptions)&&isfield(this.params.programFPGAOptions,'Command')
            programfile=h.FileName;%#ok<NASGU>
            statusmsg=evalc(this.params.programFPGAOptions.Command);
        else
            if~isempty(this.params.connectionOptions)&&strcmpi(this.params.connectionOptions.Communication_Channel,'PSEthernet')
                boardID=eda.internal.getBoardID(h.BoardName);
                deviceTree=this.params.connectionOptions.DeviceTree;
                ipAddress=this.dialogState.IPAddress;
                username=this.dialogState.Username;
                password=this.dialogState.Password;

                loadBitstream(boardID,h.FileName,deviceTree,...
                'DeviceAddress',ipAddress,...
                'Username',username,...
                'Password',password);
            else
                try
                    firstArg=this.BuildInfo.FPGATool;
                catch

                    firstArg=this.BuildInfo.BoardObj.Component.PartInfo.FPGAVendor;
                end
                arg={firstArg,...
                h.FileName,this.BuildInfo.BoardObj.Component.ScanChain};

                if isfield(this.BuildInfo.BoardObj.Component,'UseDigilentPlugin')
                    arg{end+1}=this.BuildInfo.BoardObj.Component.UseDigilentPlugin;
                end
                filProgramFPGA(arg{:});
            end
            statusmsg='FPGA programming file loaded successfully';
        end
        h.updateStatus(statusmsg);
        loadStatus=h.Status;
    catch ME
        h.updateStatus(ME.message);
        if(strcmp(ME.identifier,'fpgaautomation:loadXilinxBitstream:LoadingFailed'))
            loadStatus='Loading FPGA programming file failed';
        else
            loadStatus=h.Status;
        end
    end

    dialogH.setWidgetValue('loadStatus',['Status: ',loadStatus]);
    dlg.refresh();
end


