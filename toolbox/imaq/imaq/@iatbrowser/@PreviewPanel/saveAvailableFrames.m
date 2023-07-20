function saveAvailableFrames(this,filename,vidObj)%#ok<INUSL>















    desk=iatbrowser.getDesktop();
    desk.enableGlassPane(true);
    glassPaneSentinel=iatbrowser.GlassPaneSentinel;%#ok<NASGU>

    pd=javaObjectEDT('com.mathworks.toolbox.testmeas.guiutil.ProgressDialog',...
    iatbrowser.getDesktopFrame(),...
    imaqgate('privateGetJavaResourceString',...
    'com.mathworks.toolbox.imaq.browser.resources.RES_DESKTOP',...
    'ProgressBar.Title'),...
    imaqgate('privateGetJavaResourceString',...
    'com.mathworks.toolbox.imaq.browser.resources.RES_DESKTOP',...
    'ProgressBar.Message'),...
    1,...
    vidObj.FramesAvailable);

    pd.setModal(false);
    pd.show();
    try
        digits=ceil(log10(vidObj.FramesAvailable));
        for ii=1:vidObj.FramesAvailable
            pd.setProgress(ii);
            pd.setLabelText(...
            sprintf(imaqgate('privateGetJavaResourceString',...
            'com.mathworks.toolbox.imaq.browser.resources.RES_DESKTOP',...
            'ProgressBar.Message'),ii));
            drawnow;
            eval(sprintf(['frame_%',sprintf('0%i',digits),'i=getdata(vidObj,1);'],ii));
            if ii==1
                save(filename,sprintf(['frame_%',sprintf('0%i',digits),'i'],ii));
            else
                save(filename,sprintf(['frame_%',sprintf('0%i',digits),'i'],ii),'-append');
            end
            clear(sprintf(['frame_%',sprintf('0%i',digits),'i'],ii));
        end
    catch err
        pd.hide();
        md=iatbrowser.MessageDialog();
        md.showMessageDialogWithAdditionalMessage(...
        com.mathworks.toolbox.imaq.browser.IATBrowserDesktop.getInstance.getMainFrame,...
        'ATTEMPT_TO_SAVE_AFTER_GETDATA_FAILURE_FAILED',...
        err.getReport('basic','hyperlinks','off'),...
        [],...
        []);
        drawnow;
    end
    pd.hide();
end
