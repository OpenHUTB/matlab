function hFilesStruct=lct_pCollectAllHeaderFiles(iStruct)






    hFilesStruct.GlobalHeaderFiles={};
    hFilesStruct.SlObjHeaderFiles={};


    nb=length(iStruct.Specs.HeaderFiles);
    if nb>0
        hFilesStruct.GlobalHeaderFiles(1:nb)=iStruct.Specs.HeaderFiles(1:nb);
    end


    hFilesStruct.GlobalHeaderFiles=RTW.unique(hFilesStruct.GlobalHeaderFiles);


    for ii=(iStruct.DataTypes.NumSLBuiltInDataTypes+1):1:iStruct.DataTypes.NumDataTypes
        thisHeaderFile=strtrim(iStruct.DataTypes.DataType(ii).HeaderFile);


        if~isempty(thisHeaderFile)&&~ismember(thisHeaderFile,hFilesStruct.GlobalHeaderFiles)
            hFilesStruct.SlObjHeaderFiles{end+1}=thisHeaderFile;
        end
    end


    hFilesStruct.SlObjHeaderFiles=RTW.unique(hFilesStruct.SlObjHeaderFiles);
