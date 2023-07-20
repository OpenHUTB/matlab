function convertToExternalImage(block)


    modelName=bdroot(block);
    m=Simulink.Mask.get(block);
    if isempty(m.ImageFile)||~strncmp(m.ImageFile,'slx:/',4)

        return;
    end
    if strcmp(get_param(block,'LinkStatus'),'resolved')
        if~m.isMaskOnLinkBlock

            return;
        end
    end
    partname=m.ImageFile(5:end);
    [~,stem,ext]=slfileparts(partname);
    targetfile=slfullfile(pwd,[stem,ext]);
    if~isempty(Simulink.loadsave.resolveFile(targetfile))

        count=1;
        while~isempty(Simulink.loadsave.resolveFile(targetfile))
            targetfile=slfullfile(pwd,[stem,num2str(count),ext]);
            count=count+1;
        end
        [~,stem,ext]=slfileparts(targetfile);
    end

    extracted=m.ResolvedImageFile;
    if isempty(extracted)

        extracted=Simulink.slx.getUnpackedFileNameForPart(modelName,partname);
    end
    if~isempty(Simulink.loadsave.resolveFile(extracted))

        copyfile(extracted,targetfile);
    else

        opts=Simulink.internal.BDLoadOptions(modelName);
        r=opts.readerHandle;
        r.readPartToFile(partname,targetfile);
    end

    m.Display=['image(''',[stem,ext],''')'];
    m.ImageFile='';

end