function FileSelect(this,dialog)





    filename=this.outputFilename;
    isURL=strncmpi(this.outputFilename,'mms://',6)||...
    strncmpi(this.outputFilename,'http://',7);
    if isURL
        filename='';
    end


    writeableFileTypes=dspFileTypesToMultimediaFile;
    fileSelectionUIEntries=cell(numel(writeableFileTypes)+1,2);

    isMpeg4Supported=ismember('MPEG4',writeableFileTypes);
    isMj2000Supported=ismember('MJ2000',writeableFileTypes);


    writeableFileTypes(ismember(writeableFileTypes,{'MPEG4','MJ2000'}))=[];


    for cnt=1:numel(writeableFileTypes)
        fileSelectionUIEntries(cnt,:)=localCreateUIEntry(writeableFileTypes{cnt},writeableFileTypes{cnt});
    end

    if isMpeg4Supported
        cnt=cnt+1;
        fileSelectionUIEntries(cnt,:)=localCreateUIEntry('MPEG4','MPEG-4');
    end

    if isMj2000Supported
        cnt=cnt+1;
        fileSelectionUIEntries(cnt,:)=localCreateUIEntry('MJ2000','Motion JPEG 2000');
    end

    cnt=cnt+1;
    fileSelectionUIEntries(cnt,:)={'*.*','All Files (*.*)'};

    [filename,pathname]=uiputfile(fileSelectionUIEntries,...
    'Select output file',filename);
    if~(isequal(filename,0)||isequal(pathname,0))
        dialog.setWidgetValue('outputFilename',[pathname,filename]);
    end

    function uiEntry=localCreateUIEntry(fileType,fileTypeLabel)
        uiEntry=cell(1,2);

        fileTypeInfo=dspFileTypeInfoToMultimediaFile(fileType);
        fileExtns=union(fileTypeInfo.AudioFileExtensions,fileTypeInfo.VideoFileExtensions);

        formatStr=repmat('*%s,',[1,numel(fileExtns)]);
        formatStr=formatStr(1:end-1);
        uiEntry{1}=sprintf(formatStr,fileExtns{:});

        formatStr=repmat('*%s,',[1,numel(fileExtns)]);
        formatStr=formatStr(1:end-1);
        formatStr=sprintf('%%s Files (%s)',formatStr);
        uiEntry{2}=sprintf(formatStr,fileTypeLabel,fileExtns{:});
