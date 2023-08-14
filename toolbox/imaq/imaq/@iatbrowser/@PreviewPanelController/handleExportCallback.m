function handleExportCallback(this,~,eventdata)








    glassPaneSentinel=iatbrowser.GlassPaneSentinel;%#ok<NASGU>

    jDialog=eventdata.JavaEvent.dialog;

    browser=iatbrowser.Browser();
    vidObj=browser.currentVideoinputObject;

    switch class(eventdata.JavaEvent)
    case 'com.mathworks.toolbox.imaq.browser.DataExporterDialog$DialogDataForMATFile'
        variableName=char(eventdata.JavaEvent.variable);
        if~validVarName(variableName)
            return;
        end
        fileName=char(eventdata.JavaEvent.fileName);
        if~isempty(fileName)
            success=writeFramesToMATFile(fileName,variableName);


            if~success
                return
            end
        end
    case 'com.mathworks.toolbox.imaq.browser.DataExporterDialog$DialogDataForWorkspace'
        variableName=char(eventdata.JavaEvent.variable);
        didExport=exportVariable(variableName);

        if~didExport
            return;
        end
    case 'com.mathworks.toolbox.imaq.browser.DataExporterDialog$DialogDataForIMWRITE'
        fileName=char(eventdata.JavaEvent.fileName);
        if~isempty(fileName)





            allowedExtensions={'j2c','j2k','jp2','jpf','jpx','jpg','jpeg','png','tif','tiff'};
            [~,~,fileExt]=fileparts(fileName);

            fileExt=fileExt(2:end);

            if~any(strcmpi(allowedExtensions,fileExt))
                md=iatbrowser.MessageDialog();
                md.showMessageDialogSync(...
                iatbrowser.getDesktopFrame(),...
                'EXPORT_TO_IMAGE_FILE_ALLOWED_TYPES');
                redisplayExportDialog();
                return
            end

            try
                if(strcmpi(fileExt,'jpeg')||strcmpi(fileExt,'jpg'))&&isa(this.prevPanel.data,'uint16')
                    bitDepth=16;
                    if size(this.prevPanel.data,3)==3
                        od=iatbrowser.OptionDialog();
                        result=char(od.showOptionDialogSync(...
                        iatbrowser.getDesktopFrame(),...
                        'JPEG_EXPORT_MULITBYTE_COLOR'));
                        cancelButton=imaqgate('privateGetJavaResourceString',...
                        'com.mathworks.toolbox.imaq.browser.resources.RES_DESKTOP',...
                        'JPEG.ColorBitDepth.Cancel');
                        if strcmp(result,cancelButton)
                            redisplayExportDialog();
                            return
                        end

                        bitDepth=12;
                    end
                    imwrite(this.prevPanel.data,fileName,'BitDepth',bitDepth);

                    ed=iatbrowser.SessionLogEventData(iatbrowser.Browser().currentVideoinputObject,...
                    'imwrite(getdata(vid), ''%s'', ''BitDepth'', %d);\n\n',fileName,bitDepth);
                    iatbrowser.Browser().messageBus.generateEvent('SessionLogEvent',ed);

                else
                    imwrite(this.prevPanel.data,fileName);

                    ed=iatbrowser.SessionLogEventData(iatbrowser.Browser().currentVideoinputObject,...
                    'imwrite(getdata(vid), ''%s'');\n\n',fileName);
                    iatbrowser.Browser().messageBus.generateEvent('SessionLogEvent',ed);
                end
            catch exception
                md=iatbrowser.MessageDialog();
                md.showMessageDialogWithAdditionalMessage(...
                iatbrowser.getDesktopFrame(),...
                'IMWRITE_FAILED',...
                exception.getReport('basic','hyperlinks','off'),...
                jDialog,...
                @redisplayExportDialog);
                return;
            end
        else
            return;
        end
    case 'com.mathworks.toolbox.imaq.browser.DataExporterDialog$DialogDataForIMTOOL'
        imtool(this.prevPanel.data);

        ed=iatbrowser.SessionLogEventData(iatbrowser.Browser().currentVideoinputObject,...
        'imtool(getdata(vid));\n\n');
        iatbrowser.Browser().messageBus.generateEvent('SessionLogEvent',ed);

    case 'com.mathworks.toolbox.imaq.browser.DataExporterDialog$DialogDataForIMPLAY'
        variableName=char(eventdata.JavaEvent.variable);
        didExport=exportVariable(variableName);

        if didExport
            evalin('base',['implay(',variableName,');']);
            ed=iatbrowser.SessionLogEventData(iatbrowser.Browser().currentVideoinputObject,...
            'implay(%s);\n\n',variableName);
            iatbrowser.Browser().messageBus.generateEvent('SessionLogEvent',ed);
        else
            return;
        end
    case 'com.mathworks.toolbox.imaq.browser.DataExporterDialog$DialogDataForVideoWriter'

        gp=iatbrowser.GlassPaneSentinel;%#ok<NASGU>
        filename=char(eventdata.JavaEvent.filename);
        profile=char(eventdata.JavaEvent.profile);

        try

            [filename,fileExists]=iatbrowser.validateDiskLoggerFilename(filename,profile);
            if fileExists


                fileExistsDialog=iatbrowser.LogFilePresentDialog;
                choice=fileExistsDialog.doDialog();

                if isequal(choice,fileExistsDialog.Cancel)
                    return;
                end
            end

            diskLogger=VideoWriter(filename,profile);
            ed=iatbrowser.SessionLogEventData(iatbrowser.Browser().currentVideoinputObject,...
            'diskLogger = VideoWriter(''%s'', ''%s'');\n',...
            filename,profile);
            iatbrowser.Browser().messageBus.generateEvent('SessionLogEvent',ed);
        catch exp
            md=iatbrowser.MessageDialog();
            md.showMessageDialogWithAdditionalMessageSync(...
            iatbrowser.getDesktopFrame(),...
            'VIDEOWRITER_CREATE_FAILED',...
            sprintf('\n\n%s',exp.getReport('basic','hyperlinks','off')));
            redisplayExportDialog();
            return
        end

        proceed=showVideoWriterExportDialog(filename,profile,diskLogger);

        if~proceed
            redisplayExportDialog();
            return;
        end

        if~exportFramesToVideoWriter(diskLogger)
            redisplayExportDialog();
            return;
        end

    otherwise
    end

    cleanupExportState();

    function cleanupExportState
        this.prevPanel.clearFrames();
        buttonsPanel=java(this.prevPanel.prevPanelButtonPanel);
        javaMethodEDT('disableExportButton',buttonsPanel);
        buttonsPanel.setLastExportLocation(jDialog.getSelectedExportItem());
    end

    function valid=validVarName(variableName)
        if~isvarname(variableName)
            md=iatbrowser.MessageDialog();
            md.showMessageDialogSync(...
            iatbrowser.getDesktopFrame(),...
            'VAR_NAMING_FAILED');
            redisplayExportDialog();
            valid=false;
        else
            valid=true;
        end
    end

    function redisplayExportDialog(callbackObj,eventData)%#ok<INUSD,INUSD>
        jDialog.show();
    end

    function result=showVideoWriterExportDialog(filename,profile,logger)
        browser=iatbrowser.Browser();
        vidObj=browser.currentVideoinputObject;
        info=imaqhwinfo(vidObj);
        dataType=info.NativeDataType;
        showWarning=false;
        if~strcmp(dataType,'uint8')&&...
            ~(strcmp(profile,'Motion JPEG 2000')||strcmp(profile,'Archival'))
            showWarning=true;
        end




        d=com.mathworks.toolbox.imaq.browser.dialogs.VideoWriterExportDialog(...
        iatbrowser.getDesktopFrame(),...
        filename,...
        profile,...
        iatbrowser.VideoWriterSetter(vidObj,logger),...
        iatbrowser.convertVideoWriterPropertiesToList(logger),...
        showWarning);

        result=d.doDialog();
    end

    function success=exportFramesToVideoWriter(diskLogger)
        success=true;
        browser=iatbrowser.Browser();
        vidObj=browser.currentVideoinputObject;

        if~strcmpi(diskLogger.FileFormat,'mj2')&&~isa(this.prevPanel.data,'uint8')
            exportData=getdata(vidObj,vidObj.FramesAvailable,'uint8');







            this.prevPanel.data=exportData;
            eventString='data = getdata(vid, vid.FramesAvailable, ''uint8'');\n';
        else
            exportData=this.prevPanel.data;
            eventString='data = getdata(vid, vid.FramesAvailable);\n';
        end


        numFrames=size(exportData,4);

        pb=javaObjectEDT('com.mathworks.toolbox.testmeas.guiutil.ProgressDialog',...
        iatbrowser.getDesktopFrame(),...
        'VideoWriter Export Progress',...
        'Saving frame 0 of N',...
        1,...
        numFrames);
        pb.setModal(false);

        pb.show();


        diskLogger.open();
        ed=iatbrowser.SessionLogEventData(vidObj,...
        'open(diskLogger);\n');
        browser.messageBus.generateEvent('SessionLogEvent',ed);

        eventString=[eventString,'numFrames = size(data, 4);\n'];
        eventString=[eventString,'for ii = 1:numFrames\n'];

        ed=iatbrowser.SessionLogEventData(vidObj,...
        eventString);
        browser.messageBus.generateEvent('SessionLogEvent',ed);

        try
            for ii=1:numFrames
                pb.setLabelText(sprintf('Logging frame %d of %d',ii,numFrames));
                pb.setProgress(ii);
                writeVideo(diskLogger,exportData(:,:,:,ii));
            end
            ed=iatbrowser.SessionLogEventData(vidObj,...
            '    writeVideo(diskLogger, data(:,:,:,ii));\n');
            browser.messageBus.generateEvent('SessionLogEvent',ed);
        catch exception
            success=false;
            pb.hide();
            md=iatbrowser.MessageDialog();
            md.showMessageDialogWithAdditionalMessageSync(...
            iatbrowser.getDesktopFrame(),...
            'VIDEOWRITER_WRITE_FAILED',...
            exception.getReport('basic','hyperlinks','off'));
        end

        pb.hide();
        if strcmp(diskLogger.VideoFormat,'Indexed')&&isempty(diskLogger.Colormap)
            warning('off','MATLAB:audiovideo:VideoWriter:noFramesWritten');
            closeWarnCleanup=onCleanup(@()warning('on','MATLAB:audiovideo:VideoWriter:noFramesWritten'));
        end
        close(diskLogger);

        eventString='end\n';
        eventString=[eventString,'close(diskLogger);\n\n'];

        ed=iatbrowser.SessionLogEventData(browser.currentVideoinputObject,...
        eventString);
        browser.messageBus.generateEvent('SessionLogEvent',ed);
    end

    function success=writeFramesToMATFile(fileName,variableName)
        success=true;
        [~,~,ext]=fileparts(fileName);

        if~strcmpi(ext,'.mat')
            fileName=[fileName,'.mat'];
        end

        if exist(fileName,'file')
            od=iatbrowser.OptionDialog();
            result=char(od.showOptionDialogSync(iatbrowser.getDesktopFrame(),'MAT_FILE_PRESENT'));
            cancelOption=imaqgate('privateGetJavaResourceString',...
            'com.mathworks.toolbox.imaq.browser.resources.RES_FILEPRESENT',...
            'FilePresent.Cancel');
            if strcmp(result,cancelOption)
                success=false;
                redisplayExportDialog();
            end
        end
        try
            this.saveFramesToMATFile(fileName,variableName);
        catch exp
            success=false;
            md=iatbrowser.MessageDialog();
            md.showMessageDialogWithAdditionalMessageSync(...
            iatbrowser.getDesktopFrame(),...
            'MAT_FILE_WRITE_FAILED',...
            exp.getReport('basic','hyperlinks','off'));
            redisplayExportDialog();
        end
    end

    function didExport=exportVariable(variableName)
        didExport=false;
        if~validVarName(variableName)
            return;
        end

        if evalin('base',['exist(''',variableName,''', ''var'');'])
            od=iatbrowser.OptionDialog();
            result=od.showOptionDialogSync(...
            iatbrowser.getDesktopFrame(),...
            'WORKSPACE_VARIABLE_EXISTS');
            cancelOption=imaqgate('privateGetJavaResourceString',...
            'com.mathworks.toolbox.imaq.browser.resources.RES_DESKTOP',...
            'WorkspaceVarExists.Cancel');
            if strcmp(result,cancelOption)
                redisplayExportDialog();
                return;
            end
        end
        assignin('base',variableName,this.prevPanel.data);

        ed=iatbrowser.SessionLogEventData(iatbrowser.Browser().currentVideoinputObject,...
        '%s = getdata(vid);\n\n',variableName);
        iatbrowser.Browser().messageBus.generateEvent('SessionLogEvent',ed);
        didExport=true;
    end
end
