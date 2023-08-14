function spDocRoot=getSppkgDocRoot(sppkgInternalLocation,sppkgNameTag)











    validateattributes(sppkgNameTag,{'char'},{'nonempty'},'getSppkgDocRoot','sppkgNameTag');
    validateattributes(sppkgInternalLocation,{'char'},{'nonempty'},'getSppkgDocRoot','sppkgInternalLocation');

    spDocRoot=getHelpDir(sppkgInternalLocation,sppkgNameTag);


    function helpDir=getHelpDir(internalLocation,sppkgNameTag)




        matchIndx=regexp(internalLocation,regexptranslate('escape',[filesep,'toolbox']));
        for i=numel(matchIndx):-1:1
            dirPath=fullfile(internalLocation(1:matchIndx(i)));
            helpDir=fullfile(fileparts(dirPath),'help','supportpkg',sppkgNameTag);
            if exist(helpDir,'dir')==7
                return
            else
                helpDir='';
            end
        end


