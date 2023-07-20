function outName=getUniqueFileName(fileName,fileExtension,codeGenDir)







    assert(dltargets.internal.utils.LayerToCompUtils.isSanitizedName(fileName));
    outName=fileName;
    i=1;
    while isfile(fullfile(codeGenDir,[outName,fileExtension]))
        outName=[fileName,'_',num2str(i)];
        i=i+1;
    end
    outName=fullfile(codeGenDir,[outName,fileExtension]);

end
