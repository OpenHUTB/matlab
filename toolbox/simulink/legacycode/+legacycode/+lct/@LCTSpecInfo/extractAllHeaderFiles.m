function hFilesStruct=extractAllHeaderFiles(this)






    hFilesStruct.GlobalHeaderFiles={};
    hFilesStruct.SlObjHeaderFiles={};


    nb=length(this.Specs.HeaderFiles);
    hFilesStruct.GlobalHeaderFiles(1:nb)=this.Specs.HeaderFiles(1:nb);


    hFilesStruct.GlobalHeaderFiles=RTW.unique(hFilesStruct.GlobalHeaderFiles);


    for ii=(this.DataTypes.NumSLBuiltInDataTypes+1):1:this.DataTypes.Numel
        thisHeaderFile=strtrim(this.DataTypes.Items(ii).HeaderFile);


        if~isempty(thisHeaderFile)&&~ismember(thisHeaderFile,hFilesStruct.GlobalHeaderFiles)
            hFilesStruct.SlObjHeaderFiles{end+1}=thisHeaderFile;
        end
    end


    hFilesStruct.SlObjHeaderFiles=RTW.unique(hFilesStruct.SlObjHeaderFiles);
