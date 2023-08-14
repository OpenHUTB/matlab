function convertToInternalImage(block)


    modelName=bdroot(block);
    if isempty(modelName)||isequal(modelName,-1)

        return;
    end


    opts=Simulink.internal.BDLoadOptions(modelName);
    r=opts.readerHandle;
    if~isempty(r)
        m=r.getMatchingPartNames('/simulink/maskimages/');
        for i=1:numel(m)
            Simulink.slx.extractFileForPart(modelName,m{i});
        end
    else


        [~,~,ext]=slfileparts(get_param(modelName,'FileName'));
        if strcmp(ext,'.mdl')
            MSLDiagnostic('Simulink:Masking:InternalMaskImageNotSupportedInMDLFormat',get_param(modelName,'Name')).reportAsWarning;
        end
    end


    unpackedfolder=get_param(modelName,'UnpackedLocation');
    imagefolder=slfullfile(unpackedfolder,'simulink','maskimages');
    if isempty(Simulink.loadsave.resolveFolder(imagefolder))
        mkdir(imagefolder);
    end

    m=get_param(block,'MaskObject');
    imagefile=m.ImageFile;
    if isempty(imagefile)

        return;
    end
    [~,stem,ext]=slfileparts(imagefile);
    if strncmp(imagefile,'slx:/',5)


        m.Display=regexprep(m.Display,'image\([^\(\)]*\)','image(''$imagefile'')');
        extracted=slfullfile(unpackedfolder,imagefile(6:end));
        if~isempty(Simulink.loadsave.resolveFile(extracted))


            if strcmp(Simulink.getFileChecksum(extracted),Simulink.getFileChecksum(m.ResolvedImageFile))

                return;
            end
        end


        imagefile=m.ResolvedImageFile;
    end
    resolved=Simulink.loadsave.resolveFile(imagefile);
    if isempty(resolved)
        warning('Simulink:Masking:ImageFileNotFound','Image file not found: %s',imagefile);
        return;
    end
    stem=matlab.lang.makeValidName(stem);
    imagefolder=get_param(bdroot(block),'UnpackedLocation');
    partname=['/simulink/maskimages/',stem,ext];
    internalfile=slfullfile(imagefolder,partname);
    count=1;
    while~isempty(Simulink.loadsave.resolveFile(internalfile))

        partname=['/simulink/maskimages/',stem,num2str(count),ext];
        internalfile=slfullfile(imagefolder,partname);
        count=count+1;
    end
    copyfile(resolved,internalfile);
    m.ImageFile=['slx:',partname];
    m.Display=regexprep(m.Display,'image\([^\(\)]*\)','image(''$imagefile'')');

end