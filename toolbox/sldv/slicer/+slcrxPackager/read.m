function cvd=read(packageName,mdl)



    cvt=[];%#ok<NASGU>
    covData=[];%#ok<NASGU>
    scratchDir=tempname;
    mkdir(scratchDir);


    cvtFile=[scratchDir,filesep,'covfile.cvt'];

    matFile=[scratchDir,filesep,'streamData.mat'];

    try

        slcrxPackager.mexHelper('getSlicerData',packageName,matFile,cvtFile);
    catch ex

        rmdir(scratchDir,'s');
        Mex=MException('ModelSlicer:BadSlcrxPackage',...
        getString(message('Sldv:ModelSlicer:Coverage:BadSlcrxPackage')));
        Mex.addCause(ex);
        throw(Mex);
    end

    try

        covData=Coverage.loadCVTFile(cvtFile,mdl);
    catch mex
        rethrow(mex);
    end


    savedData=load(matFile);
    covStreamMap=savedData.covStreamMap;
    simData=savedData.simData;
    covIdDfsMap=Coverage.buildCovIdDfsMap(covData{1});


    cvd=Coverage.CovData(covData{1},covStreamMap,covIdDfsMap,simData);


    rmdir(scratchDir,'s');
end
