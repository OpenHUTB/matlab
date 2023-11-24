function loadConfigurationFile(this,filename)%#ok<INUSL>

    browser=iatbrowser.Browser;
    browser.acqParamPanel.stopPropertyUpdateTimer();

    load('-mat',filename);

    try

        for ii=1:length(configurations)%#ok<NODEF>
            if~isvalid(configurations(ii).obj)
                errorMsgStr1=iatbrowser.getResourceString('RES_DESKTOP',...
                'OpenConfig.FailedLoad.String1');
                errorMsgStr2=iatbrowser.getResourceString('RES_DESKTOP',...
                'OpenConfig.FailedLoad.String2');
                errorMsgStr3=iatbrowser.getResourceString('RES_DESKTOP',...
                'OpenConfig.FailedLoad.String3');
                errorMsgStr4=iatbrowser.getResourceString('RES_DESKTOP',...
                'OpenConfig.FailedLoad.String4');
                errorMsgStr5=iatbrowser.getResourceString('RES_DESKTOP',...
                'OpenConfig.FailedLoad.String5');
                errorMsg=sprintf('%s %s %s %s %s%s%s',...
                errorMsgStr1,...
                configurations(ii).deviceName,...
                errorMsgStr2,...
                configurations(ii).format,...
                errorMsgStr3,...
                errorMsgStr4,...
                errorMsgStr5);
                md=iatbrowser.MessageDialog();
                md.showMessageDialogWithAdditionalMessage(...
                iatbrowser.getDesktopFrame(),...
                'OPEN_CONFIG_LOAD_FAILED',...
                errorMsg,...
                [],...
                []);
            end
        end


        desk=iatbrowser.getDesktop();
        desk.enableGlassPane(true);
        glassPaneSentinel=iatbrowser.GlassPaneSentinel;%#ok<NASGU>
        drawnow;


        for ii=length(configurations):-1:1
            if~isvalid(configurations(ii).obj)
                configurations(ii)=[];
            end
        end
    catch %#ok<CTCH>
        md=iatbrowser.MessageDialog();
        md.showMessageDialog(...
        iatbrowser.getDesktopFrame(),...
        'OPEN_CONFIG_IAT_FILE_FAILED',...
        [],...
        []);
        return;
    end

    for ii=1:length(configurations)
        configurations(ii).adaptorName=imaqgate('privateTranslateAdaptor',configurations(ii).adaptorName);%#ok<AGROW>
    end
    browser.loadSavedObjects(configurations);

    browser.acqParamPanel.startPropertyUpdateTimer();

    drawnow;

end