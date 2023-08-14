function diskLogger=createDiskLogger(filename,profileName,oldLogger)












    browser=iatbrowser.Browser();
    vidObj=browser.currentVideoinputObject;
    acqParam=browser.acqParamPanel;

    try
        diskLogger=VideoWriter(filename,profileName);
        ed=iatbrowser.SessionLogEventData(vidObj,...
        'diskLogger = VideoWriter(''%s'', ''%s'');\n\n',...
        filename,profileName);
        iatbrowser.Browser().messageBus.generateEvent('SessionLogEvent',ed);

        if isempty(oldLogger)
            source=getselectedsource(vidObj);
            if ismember('FrameRate',fieldnames(source))
                framerate=source.FrameRate;
                if~isnumeric(framerate)
                    try
                        framerate=str2double(framerate);
                    catch %#ok<CTCH>


                        framerate=diskLogger.FrameRate;
                    end
                end
                try
                    diskLogger.FrameRate=framerate;
                catch %#ok<CTCH>


                end
            end
        else
            settings=set(oldLogger);
            props=fieldnames(settings);
            for ii=1:length(props)
                if isequal(diskLogger.(props{ii}),oldLogger.(props{ii}))
                    continue;
                end
                diskLogger.(props{ii})=oldLogger.(props{ii});
                ed=iatbrowser.SessionLogEventData(vidObj,...
                'diskLogger.%s = %s;\n\n',props{ii},num2str(oldLogger.(props{ii})));
                iatbrowser.Browser().messageBus.generateEvent('SessionLogEvent',ed);
            end
        end

        acqParam.videoWriterProfile=profileName;

    catch %#ok<CTCH>

        diskLogger=[];
        formatNodePanel=javaMethodEDT('getFormatNodePanel',java(acqParam.javaPeer));

        if strcmpi(vidObj.LoggingMode,'memory')
            formatNodePanel.setInvalidFilenameSpecified(true);
            return;
        end

        formatNodePanel.disableFileNameListeners();
        md=iatbrowser.MessageDialog();
        md.showMessageDialog(...
        iatbrowser.getDesktopFrame(),...
        'VIDEOWRITER_CREATE_FAILED',...
        [],...
        @(obj,event)formatNodePanel.enableFileNameListeners());
        return;
    end

end
