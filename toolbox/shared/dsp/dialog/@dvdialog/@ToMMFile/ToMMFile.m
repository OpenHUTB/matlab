function this=ToMMFile(block)








    this=dvdialog.ToMMFile(block);

    this.init(block);

    this.outputFilename=this.Block.outputFilename;
    this.streamSelection=this.Block.streamSelection;
    this.imagePorts=this.Block.imagePorts;
    this.audioDatatype=this.Block.audioDatatype;
    this.fileColorspace=this.Block.fourcc;
    this.fileType=dspFileTypesToMultimediaFile;
    this.videoQuality=this.Block.videoQuality;
    this.mj2000CompFactor=this.Block.mj2000CompFactor;

    if ismember(this.Block.fileType,this.fileType)
        this.fileTypePopup=this.Block.fileType;
    else
        this.fileTypePopup='AVI';
        msg=getString(message('dspshared:ToMMFile:TheSpecifiedFileType',this.Block.fileType));
        uiwait(warndlg(msg,getString(message('dspshared:ToMMFile:ToMMFileFormatNotSupported'))));
    end





    fileTypeInfo=dspFileTypeInfoToMultimediaFile(this.fileTypePopup);



    if~isempty(fileTypeInfo.AudioCompressors)

        if ismember(this.Block.audioCompressor,fileTypeInfo.AudioCompressors)
            this.audioCompressorPopup=this.Block.audioCompressor;
        else
            this.audioCompressorPopup=fileTypeInfo.DefaultAudioCompressor;
            if~isempty(strfind(this.streamSelection,'udio'))
                msg=getString(message('dspshared:ToMMFile:CouldNotFindTheSpecifiedAudio',this.Block.audioCompressor));
                uiwait(warndlg(msg,getString(message('dspshared:ToMMFile:ToMultimediaFileCodecNotFound'))));
            end
        end
    else
        this.audioCompressorPopup=this.Block.audioCompressor;
    end



    if~isempty(fileTypeInfo.VideoCompressors)
        if ismember(this.Block.videoCompressor,fileTypeInfo.VideoCompressors)
            this.videoCompressorPopup=this.Block.videoCompressor;
        else
            this.videoCompressorPopup=fileTypeInfo.DefaultVideoCompressor;
            if~isempty(strfind(this.streamSelection,'idio'))
                msg=getString(message('dspshared:ToMMFile:CouldNotFindTheSpecifiedVideo',this.Block.videoCompressor));
                uiwait(warndlg(msg,getString(message('dspshared:ToMMFile:ToMultimediaFileCodecNotFound'))));
            end
        end
    else
        this.videoCompressorPopup=this.Block.videoCompressor;
    end
