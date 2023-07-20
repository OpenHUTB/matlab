function match=matchSharedUtilityCS(modelName,...
    librarySharedUtilsDir,thisModelSharedUtilsDir)



    libSharedUtilsCSFile=fullfile(librarySharedUtilsDir,'checksummap.mat');
    thisModelSharedUtilsCSFile=fullfile(thisModelSharedUtilsDir,'checksummap.mat');

    libSharedUtilshashTbl=load(libSharedUtilsCSFile);
    thisModelSharedUtilshashTbl=load(thisModelSharedUtilsCSFile);


    comp=coder.internal.SharedUtilsChecksumComparison(modelName,...
    thisModelSharedUtilsDir,...
    thisModelSharedUtilshashTbl.hashTbl,...
    libSharedUtilshashTbl.hashTbl);
    match=~comp.DifferencesExist;
end
