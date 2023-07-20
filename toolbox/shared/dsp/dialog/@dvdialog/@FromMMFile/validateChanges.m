function errmsg=validateChanges(h)





    errmsg='';

    try
        h.inputFilename=strtrim(h.inputFilename);
        if isempty(h.inputFilename)
            error(message('dspshared:validateChanges:invalidFcnInput'));
        end


        foundFilename=dspmaskFromMultimediaFile('searchForFile',h.inputFilename);
    catch Err
        errmsg=Err.message;
        return;
    end

    if(isempty(foundFilename))


        [videoFileInfo,audioFileInfo]=dspaudiovideofileinfo(this.inputFilename);
    else

        [videoFileInfo,audioFileInfo]=dspaudiovideofileinfo(foundFilename);
    end

    if isempty(videoFileInfo)&&isempty(audioFileInfo)
        [~,~,file_ext]=fileparts(h.inputFilename);
        if exist(h.inputFilename,'file')==2
            if strcmpi(file_ext,'.mov')==1
                errmsg=getString(message('dspshared:validateChanges:quickTimeVersionNotSupported'));
            else
                errmsg=getString(message('dspshared:validateChanges:UnsupportedFileFormat'));
            end
        else
            errmsg=getString(message('dspshared:validateChanges:FileDoesNotExist'));
        end
        return
    end

    if~h.inheritSampleTime
        if h.userDefinedSampleTime<=0.0
            errmsg=getString(message('dspshared:validateChanges:SampleTimeNotGTZero'));
            return
        end
    end

    h.Block.fourcc=h.outputFormat;
    h.Block.outputStreams=h.outputStreamsPopup;


