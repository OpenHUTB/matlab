function errmsg=validateChanges(this)





    errmsg='';


    if ispc
        isURL=strncmpi(this.Block.outputFilename,'mms://',6)||...
        strncmpi(this.Block.outputFilename,'http://',7);
    else
        isURL=false;
    end

    [path,file,file_ext]=fileparts(this.Block.outputFilename);

    appendFileType=false;
    if isURL

        ndx=strfind(this.outputFilename,':');
        if length(ndx)~=2
            errmsg='The URL must be specified as follows: http://127.0.0.1:1234';
        end
    else

        fileTypeInfo=dspFileTypeInfoToMultimediaFile(this.fileTypePopup);


        if~isempty(strfind(this.streamSelection,'Video'))
            validFileExtensions=fileTypeInfo.VideoFileExtensions;
        else

            validFileExtensions=fileTypeInfo.AudioFileExtensions;
        end
        if~ismember(lower(file_ext),validFileExtensions)
            outFilename=fullfile(path,[file,validFileExtensions{1}]);
            appendFileType=true;
        end
    end




    if isempty(errmsg)
        this.Block.streamSelection=this.streamSelection;
        if~isempty(this.audioCompressorPopup)
            this.Block.audioCompressor=this.audioCompressorPopup;
        end
        if~isempty(this.videoCompressorPopup)
            this.Block.videoCompressor=this.videoCompressorPopup;
        end
        this.Block.fileType=this.fileTypePopup;
        if~isempty(this.fileColorspace)
            this.Block.fourcc=this.fileColorspace;
        end
        if(appendFileType)
            this.Block.outputFilename=outFilename;
            this.outputFilename=outFilename;
        end
    end

