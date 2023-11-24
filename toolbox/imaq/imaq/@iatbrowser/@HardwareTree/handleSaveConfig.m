function handleSaveConfig(this,obj,event)%#ok<INUSD,INUSD>

    browser=iatbrowser.Browser;
    vids=browser.getAllVideoinputObjects;

    frame=iatbrowser.getDesktopFrame();
    dia=com.mathworks.toolbox.imaq.browser.dialogs.objectExporter.IATFileExporter(vids,pwd);

    okCallback=handle(dia.getOKCallback());
    this.saveButtonsListener=handle.listener(okCallback,'delayed',@handleOkCallback);

    helpCallback=handle(dia.getHelpCallback());
    this.saveButtonsListener(2)=handle.listener(helpCallback,'delayed',@handleHelp);

    dia.showAsDialog(frame);

    drawnow;
    function handleOkCallback(obj,event)%#ok<INUSL>
        callbackData=event.JavaEvent;
        if isempty(callbackData)||callbackData.videoInputObjects.isEmpty()

            return;
        end


        desk=iatbrowser.getDesktop();
        desk.enableGlassPane(true);
        glassPaneSentinel=iatbrowser.GlassPaneSentinel;%#ok<NASGU>
        drawnow;

        filename=char(callbackData.filename);
        vidObjs=[];
        for ii=1:callbackData.videoInputObjects.size()
            if ii==1
                vidObjs=handle(callbackData.videoInputObjects.elementAt(ii-1).getUDDObj);
            else
                vidObjs(end+1)=handle(callbackData.videoInputObjects.elementAt(ii-1).getUDDObj);%#ok<AGROW>
            end
        end

        vidObjs=imaqgate('privateUDDToMATLAB',vidObjs);


        for ii=1:length(vidObjs)
            configurations(ii).obj=vidObjs(ii);%#ok<AGROW>
            tempDeviceName=char(callbackData.videoInputObjects.elementAt(ii-1).getDeviceName());
            toks=regexp(tempDeviceName,'(.*)\([a-z]+\-[0-9]+\)','tokens');
            deviceName=toks{1}{1};

            deviceName=regexprep(deviceName,'\s*$','');

            configurations(ii).deviceName=deviceName;%#ok<AGROW>
            toks=regexp(tempDeviceName,'.*\(([a-z]+)\-([0-9]+)\)','tokens');
            configurations(ii).adaptorName=toks{1}{1};%#ok<AGROW>
            configurations(ii).deviceID=toks{1}{2};%#ok<AGROW>
            configurations(ii).format=char(callbackData.videoInputObjects.elementAt(ii-1).getFormat());%#ok<AGROW>
            configurations(ii).sessionLog=browser.SessionLogPanelController.getLogForObject(vidObjs(ii));%#ok<AGROW>
        end


        IATFileVersion=sprintf('%1.1f',1.1);%#ok<NASGU>

        try

            save(filename,'configurations','IATFileVersion');
        catch err
            md=iatbrowser.MessageDialog();
            md.showMessageDialogWithAdditionalMessage(...
            com.mathworks.toolbox.imaq.browser.IATBrowserDesktop.getInstance.getMainFrame,...
            'ATTEMPT_TO_SAVE_CONFIG_FAILED',...
            err.message,...
            [],...
            []);
            drawnow;
        end
        for ii=1:length(vidObjs)
            userData=get(vidObjs(ii),'UserData');
            userData.IsSaved=true;
            set(vidObjs(ii),'UserData',userData);
        end
        this.updateFormatNodesDisplay();
        drawnow;
    end

    function handleHelp(obj,event)%#ok<INUSD>
        helpview(fullfile(docroot,'toolbox','imaq','imaq.map'),'save_config');
    end
end
