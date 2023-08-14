function fileToUseInMemory=createTargetModel(mineFile,tempDir,jIsValidName)



    import com.mathworks.comparisons.util.ResourceManager;
    targetNameBase=char(ResourceManager.getString(...
    java.lang.String('target.base.name')...
    ));

    [~,~,mineExt]=fileparts(mineFile);

    targetDir=fullfile(tempDir,'tgt');
    if(~exist(targetDir,'dir'))
        mkdir(targetDir);
    end

    validTargetName=targetNameBase;
    nameVersion=0;
    while(~isValidName(validTargetName)||exist(getTargetFile(),'file')~=0)
        validTargetName=[targetNameBase,num2str(nameVersion)];
        nameVersion=nameVersion+1;
    end

    targetFile=getTargetFile();

    copyfile(mineFile,targetFile);
    fileToUseInMemory=targetFile;

    function file=getTargetFile()
        file=fullfile(targetDir,[validTargetName,mineExt]);
    end

    function isValid=isValidName(name)
        isValid=~bdIsLoaded(name)...
        &&jIsValidName.evaluate(name);
    end

end
