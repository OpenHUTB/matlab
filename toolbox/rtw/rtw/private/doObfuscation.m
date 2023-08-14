function doObfuscation(mdlName,level,noConstantHeader)






    if strcmp(get_param(0,'AcceleratorUseTrueIdentifier'),'on')
        return;
    end

    markerHeaderFile=['__cf_',mdlName,'.h'];
    markerTextFile=['__ofc_',mdlName,'.txt'];



    if isfile(markerHeaderFile)||isfile(markerTextFile)
        return
    end


    obfuscate('.','.',mdlName,level,noConstantHeader);


    if noConstantHeader&&~isfile(markerTextFile)
        fclose(fopen(markerTextFile,'w'));
    end


    fileList=dir;
    for i=1:length(fileList)
        currentFile=fileList(i).name;
        originalFile=regexprep(currentFile,'_ofc\.([ch](pp)?)$','.$1');


        if~strcmp(currentFile,originalFile)
            movefile(currentFile,originalFile);
        end
    end


