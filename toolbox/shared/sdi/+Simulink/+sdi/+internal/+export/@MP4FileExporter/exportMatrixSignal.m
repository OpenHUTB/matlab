function success=exportMatrixSignal(this,sig,bCmdLine)



    fw=Simulink.sdi.internal.AppFramework.getSetFramework();
    wksParser=Simulink.sdi.internal.import.WorkspaceParser.getDefault();
    if~isempty(this.ProgressTracker)



        this.ProgressTracker.changeMaxValue(15);
    end


    if~ismac&&~ispc
        this.displayError(message('SDI:sdi:UnsupportedOS'),bCmdLine);
    end


    repo=sdi.Repository(1);
    locErrorIfSignalNotSupported(this,repo,sig,bCmdLine)


    data=sig.Values.Data;
    locCheckCancelAndIncProgress(this,fw,wksParser,1)





    if numel(sig.Dimensions)==2&&ndims(data)==3
        dim=size(data);
        data=reshape(data,dim(1),dim(2),1,dim(3));
    end
    locCheckCancelAndIncProgress(this,fw,wksParser,1)



    if numel(sig.Dimensions)>ndims(data)
        if ismatrix(data)
            data=permute(data,[2,1]);
        elseif ndims(data)==3
            data=permute(data,[2,1,3]);
        elseif ndims(data)==4
            data=permute(data,[2,1,3,4]);
        end
    end
    locCheckCancelAndIncProgress(this,fw,wksParser,1)



    if sig.ImageLayout==1
        data=locConvertRowToColumnMajor(data);
    end
    locCheckCancelAndIncProgress(this,fw,wksParser,1)


    try
        vidWriter=VideoWriter(this.FileName,'MPEG-4');
        vidWriter.Quality=100;
    catch me
        if strcmp(me.identifier,'MATLAB:audiovideo:VideoWriter:fileNotWritable')
            this.displayError(message('SDI:sdi:InvalidFileName',this.FileName),bCmdLine);
        elseif strcmp(me.identifier,'MATLAB:audiovideo:VideoWriter:folderNotFound')
            [folder,~,~]=fileparts(this.FileName);
            this.displayError(message('SDI:sdi:InvalidFolder',folder),bCmdLine);
        else
            this.displayError(message('SDI:sdi:GenericVideoWriterError',sig.Name),bCmdLine);
        end
    end
    locCheckCancelAndIncProgress(this,fw,wksParser,1)


    warningState=warning('off','all');
    cleanup=onCleanup(@()warning(warningState));


    try
        open(vidWriter);
        locCheckCancelAndIncProgress(this,fw,wksParser,1)
        writeVideo(vidWriter,data);
        locCheckCancelAndIncProgress(this,fw,wksParser,8)
        close(vidWriter);
        locCheckCancelAndIncProgress(this,fw,wksParser,1)
    catch


        delete(this.FileName);
        this.displayError(message('SDI:sdi:GenericVideoWriterError',sig.Name),bCmdLine);
    end


    success=true;
end


function locErrorIfSignalNotSupported(this,repo,sig,bCmdLine)



    if~strcmp(sig.Complexity,'real')
        this.displayError(message('SDI:sdi:UnsupportedSignalType',sig.Complexity),bCmdLine);
    end


    if~repo.isUnexpandedMatrix(sig.ID)
        this.displayError(message('SDI:sdi:ExpandedMatricesUnsupported'),bCmdLine);
    end



    supportedTypes={'single','double','uint8'};
    if~(ismember(class(sig.Values.Data),supportedTypes)&&...
        (numel(sig.Dimensions)==2||numel(sig.Dimensions)==3))

        this.displayError(message('SDI:sdi:UnsupportedDataType'),bCmdLine);
    end




    supportedColorFormats=[1,3];
    if sig.ImageColorFormat>=0&&~ismember(sig.ImageColorFormat,supportedColorFormats)
        this.displayError(message('SDI:sdi:UnsupportedColorFormat',sig.Name),bCmdLine);
    end
end


function newData=locConvertRowToColumnMajor(data)

    height=size(data,1);
    width=size(data,2);
    nChannels=1;
    nFrames=1;

    if ndims(data)>=3 %#ok<ISMAT> 
        nChannels=size(data,3);
    end
    if ndims(data)>=4
        nFrames=size(data,4);
    end

    newData=data;

    for f=1:nFrames
        imgSize2D=height*width;
        srcData=data(:,:,:,f);
        dstData=srcData;
        for row=0:height-1
            for col=0:width-1
                for dim=0:nChannels-1
                    dstOffset=(dim*imgSize2D+col*height+row)+1;
                    srcOffset=((row*width+col)*nChannels+dim)+1;
                    dstData(dstOffset)=srcData(srcOffset);
                end
            end
        end
        newData(:,:,:,f)=dstData;
    end
end


function locCheckCancelAndIncProgress(this,fw,wksParser,inc)
    if fw.isImportCancelled()
        wksParser.IsImportCancelled=true;
        error('cancel')
    end
    if~isempty(this.ProgressTracker)
        curVal=this.ProgressTracker.getCurrentProgressValue();
        this.ProgressTracker.setCurrentProgressValue(curVal+inc);
    end
end