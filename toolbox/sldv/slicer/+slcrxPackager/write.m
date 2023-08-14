function packageName=write(cvd,modelH,settings,packageName)



    if nargin<4||isempty(packageName)

        packageName=Sldv.utils.settingsFilename('$ModelName$','on',...
        '.slslicex',modelH,false,...
        true,settings,'Model Slicer');
    else
        settings.OutputDir=fileparts(packageName);
        packageName=Sldv.utils.settingsFilename(packageName,'on',...
        '.slslicex',modelH,false,...
        true,settings);
    end


    scratchDir=tempname;
    mkdir(scratchDir);


    cvtFile=[scratchDir,filesep,'covfile.cvt'];
    SlCov.CoverageAPI.saveCoverage(cvtFile,cvd.data);


    matFile=[scratchDir,filesep,'streamData.mat'];
    covStreamMap=cvd.covStreamMap;
    simData=cvd.simData;
    save(matFile,'covStreamMap','simData');


    slcrxPackager.mexHelper('setSlicerData',packageName,matFile,cvtFile);


    rmdir(scratchDir,'s');

end
